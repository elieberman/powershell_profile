function prompt {

    #Assign Windows Title Text
    $host.ui.RawUI.WindowTitle = "Current Folder: $pwd"

    #Configure current user, current folder and date outputs
    $CmdPromptCurrentFolder = Split-Path -Path $pwd -Leaf
    $CmdPromptUser = [Security.Principal.WindowsIdentity]::GetCurrent();
    $Date = Get-Date -Format 'dddd hh:mm:ss tt'

    # Test for Admin / Elevated
    $IsAdmin = (New-Object Security.Principal.WindowsPrincipal ([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

    #Calculate execution time of last cmd and convert to milliseconds, seconds or minutes
    $LastCommand = Get-History -Count 1
    if ($lastCommand) { $RunTime = ($lastCommand.EndExecutionTime - $lastCommand.StartExecutionTime).TotalSeconds }

    if ($RunTime -ge 60) {
        $ts = [timespan]::fromseconds($RunTime)
        $min, $sec = ($ts.ToString("mm\:ss")).Split(":")
        $ElapsedTime = -join ($min, " min ", $sec, " sec")
    }
    else {
        $ElapsedTime = [math]::Round(($RunTime), 2)
        $ElapsedTime = -join (($ElapsedTime.ToString()), " sec")
    }

    #Decorate the CMD Prompt
    Write-Host ""
    Write-host ($(if ($IsAdmin) { 'Elevated ' } else { '' })) -BackgroundColor DarkRed -ForegroundColor White -NoNewline
    Write-Host " USER:$($CmdPromptUser.Name.split("\")[1]) " -BackgroundColor DarkBlue -ForegroundColor White -NoNewline
    If ($CmdPromptCurrentFolder -like "*:*")
        {Write-Host " $CmdPromptCurrentFolder "  -ForegroundColor White -BackgroundColor DarkGray -NoNewline}
        else {Write-Host ".\$CmdPromptCurrentFolder\ "  -ForegroundColor White -BackgroundColor DarkGray -NoNewline}

    Write-Host " $date " -ForegroundColor White
    Write-Host "[$elapsedTime] " -NoNewline -ForegroundColor Green
    return "> "
} #end prompt function


# Custom functions
function ifp { $global:fpumps = import-csv c:\users\liebe.sa\documents\github\724status\dat\fpumps.csv }

function copyto {$sessionJob = new-pssession -ComputerName $args[0] ; invoke-command $sessionjob -scriptblock {mkdir c:\temp} ; copy $args[1] c:\temp -tosession $sessionjob}

function explore_here {
explorer $pwd.path
}

function 724_install {
invoke-command $args[0] -scriptblock {
 c:\724Access\cygwin\bin\bash.exe --login -c "cygrunsrv --stop d7a_sshd"
 c:\724Access\cygwin\bin\bash.exe --login -c "cygrunsrv --remove d7a_sshd"
if ($using:args[1]){
Expand-Archive -path C:\temp\"$($using:args[1])".zip -DestinationPath $env:temp\ -force
}
else{
Expand-Archive -path C:\temp\UHSPA7241*.zip -DestinationPath $env:temp\ -force
}
cd $env:temp
$(gci vc*).name | %{ &.\$_ /quiet /norestart}
Set-ExecutionPolicy RemoteSigned
 &$env:temp\7x24DTVinstall.ps1
} -asjob
}
function all_job_output {
receive-job * -keep
}
# Custom Aliases
set-alias -Name gj  -Value Get-job
set-alias -Name rj  -Value all_job_output
set-alias -Name cp2 -Value copyto
set-alias -Name ep  -Value enter-pssession
set-alias -Name expl -Value explore_here
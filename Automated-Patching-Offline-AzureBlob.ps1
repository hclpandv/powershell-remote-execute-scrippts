<#
.SYNOPSIS
    Script uses azcopy and sas token uris to download media from Az storage blob
    Invoke-RestMethod "https://dmtestsesydney.blob.core.windows.net/windowsupdate/Patch-VM.ps1?sp=r&st=2021-09-08T10:15:11Z&se=2021-09-10T18:15:11Z&spr=https&sv=2020-08-04&sr=b&sig=tmPD%2BKKN9bgX7DWGPvh%2BV%2F3jkYbrwvGCmU8Ktp5eLkQ%3D" | powershell
#>

#---------------
#---- Variables
#---------------
[string]$LogDir        = "C:\updates"
[string]$UpdateDir     = "C:\updates"
[string]$VmHostName    = $env:COMPUTERNAME
[string]$timeStamp     = $(get-date -f MMddyyyy)
[string]$LogFile       = "$LogDir\auto-patching-$VmHostName-$timeStamp.log"
[string]$payloadDir    = "27082021"
[string]$sasToken      = "sas_tocken"
[string]$blobUri       = "https://vikistorageaccount.blob.core.windows.net/windowsupdate/$($payloadDir)?$sasToken"
[string]$blobLogUri    = "https://vikistorageaccount.blob.core.windows.net/windowsupdate/Logs/?$sasToken"
[string]$azcopyURI     = "https://vikistorageaccount.blob.core.windows.net/windowsupdate/azcopy.exe?$sasToken" 
#----------------------------
#---- Functions and workflows
#----------------------------
Function Write-Log {
    Param (
        [Parameter(Mandatory = $True, Position = 0)] [String] $Message,
        [string]$LogDir = "C:\updates",
        [string]$VmHostName = $env:COMPUTERNAME,
        [string]$timeStamp = $(get-date -f MMddyyyy),
        [string]$LogFile = "$LogDir\auto-patching-$VmHostName-$timeStamp.log"
    )    
    # Create log directory when needed
    If ((Test-Path -Path $LogDir) -eq $False) {
        New-Item $LogDir -Type Directory | Out-Null
    }
    $TimeStamp = "[" + (Get-Date -Format dd-MM-yy) + "," + (Get-Date -Format HH:mm:ss) + "] "
    $Log = $TimeStamp + $Message 
    # Write to screen
    Write-Host -Object $Message   
    # Write to log file
    Add-Content -Path $LogFile -Value $Log
}
Function Register-ScTask {
    param ([string]$taskName = "ResumeWFJobTask")
    $updateDir = "C:\updates"
    $scriptFile = "$updateDir\Resume-WFJob.ps1"
    "Import-Module PSWorkflow;Get-Job -State Suspended | Resume-Job -Wait| Wait-Job" > $scriptFile
    $resumeActionscript = "-WindowStyle Normal -NoLogo -NoProfile -File `"$scriptFile`""
    Get-ScheduledTask -TaskName $taskName -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false
    $act = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument $resumeActionscript
    $trig = New-ScheduledTaskTrigger -AtLogOn -RandomDelay 00:00:55
    Register-ScheduledTask -TaskName $taskName -Action $act -Trigger $trig -RunLevel Highest  
}
Function UploadLogTo-Blob {
    Param (
        [string]$LogDir = "C:\updates",
        [string]$UpdateDir = "C:\updates",
        [string]$VmHostName = $env:COMPUTERNAME,
        [string]$timeStamp = $(get-date -f MMddyyyy),
        [string]$LogFile = "$LogDir\auto-patching-$VmHostName-$timeStamp.log",
        [string]$payloadDir = "27082021",
        [string]$sasToken      = "sas_tocken",
        [string]$blobLogUri    = "https://vikistorageaccount.blob.core.windows.net/windowsupdate/Logs/?$sasToken",
        [string]$azcopyURI     = "https://vikistorageaccount.blob.core.windows.net/windowsupdate/azcopy.exe?$sasToken" 
    )    
    Write-Output "upload the logfile to blob"
    & $UpdateDir/azcopy.exe copy $LogFile $blobLogUri --overwrite=true
    if ($?) { Write-Output "Logfile upload successful" }
}

Workflow Update-PatchAvDefinition {
    Param (
        $UpdateDir = "C:\updates",
        $payloadDir = "27082021"
    )
    sequence {
        Write-Log "--------------------------------------------------"
        Write-Log "Starting the automated patching workflow"
        Write-Log "Update Defender AV definitions"
        Start-Process -FilePath "$UpdateDir\$payloadDir\mpam-fe.exe" -Wait
        $targetKB = Get-ChildItem $UpdateDir\$payloadDir | Where-Object { $_.name -like "*win2016*" }
        Write-Log "Installing patch: $($targetKB.FullName)"
        #Start-Process -Wait wusa -ArgumentList "/update $targetKB.FullName","/quite","/norestart"
        Restart-Computer -Wait 
        Write-Log "validating AV Definition"
        Write-Log $(Get-MpComputerStatus | Select-Object AntivirusEnabled, AntivirusSignatureLastUpdated, AntispywareEnabled, AntispywareSignatureLastUpdated | Out-String)
        Write-Log "validating KB articles installed"
        write-log $(Get-HotFix | Select-Object -First 8 | Out-String) 
        Write-Log "removing scheduled task"
        Unregister-ScheduledTask -TaskName ResumeWFJobTask -Confirm:$false
        Write-Log "Uploading the log file"
        UploadLogTo-Blob
    }
}

#---------------
#---- Main
#---------------
Write-Log "--------------------------------------------------"
Write-Log "Starting Copy from Azure blob"

Write-Log "Copy azcopy.exe from Azure blob"
Invoke-WebRequest -Uri $azcopyURI -OutFile "$updateDir\azcopy.exe"
if ($?) { Write-Log "azcopy download successful" }


Write-Log "Copy payload from Azure blob"
& $UpdateDir/azcopy.exe copy $blobUri $UpdateDir --overwrite=true --recursive --from-to=BlobLocal --check-md5 "FailIfDifferent"
if ($?) { Write-Log "payload download successful" }


Write-Log "Setting up scheduled task to re-start the workflow after reboot"
Register-ScTask

Write-Log "Execute workflow"
#Invoke-Expression -Command $updateDir/$payloadDir/workflow-patching.ps1
Update-PatchAvDefinition
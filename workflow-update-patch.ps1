Function Write-Log {
    Param (
        [Parameter(Mandatory = $True, Position = 0)] [String] $Message,
        [string]$LogDir = "C:\Users\vikis\Desktop",
        [string]$LogFile = "$LogDir\patching.log"
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

Workflow Update-PatchAvDefinition
{
    sequence {
        Write-Log "--------------------------------------------------"
        Write-Log "Starting to Setup Windows 10 as DevOps Workstation"
        Write-Log "download patch"
        Write-Log "download AV definition"
        Write-Log "install patch"
    }
    #Restart-Computer -Wait 
    sequence{
        Write-Log "validate"
    }
}
# Run the workflow
Update-PatchAvDefinition
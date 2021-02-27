<#
.SYNOPSIS
   Call a script and excute on an Azure VM.
   Script will be executed via pipeline
#>

param(
   [string]$VMName   = "vm01",
   [string]$RGName   = "RG_Vikas.Pandey",
   $ScriptPath       = ".\installChocoPkg.ps1"
)

#--- Check if VM exist and wait for 5 seconds to wait if the VM provisioned right away
$vmExists = Get-AzVM -ResourceGroupName $RGName -name $VMName -ea SilentlyContinue
if($vmExists){
   #wait
   Start-Sleep -Seconds 5
}
else{
   Write-Output "VM $($VMName) not found. exiting .."
   esit 1
}

# run command
Invoke-AzVMRunCommand -ResourceGroupName $RGName `
   -Name $VMName `
   -CommandId 'RunPowerShellScript' `
   -ScriptPath $ScriptPath `
   -Parameter @{"chocoPkg" = "git"} `
   -Verbose

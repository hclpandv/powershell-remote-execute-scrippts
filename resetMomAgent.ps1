<#
.SYNOPSIS
  To reset MOM agent on any server 

#>

$momServiceName = "HealthService"
$momService = Get-Service -Name $momServiceName  -ea SilentlyContinue

#--------------
# Stop Service
#--------------
if($momService){
    Write-Output "Stoping the Service $($momServiceName)"
    try{
       $momService | Stop-Service -Verbose -Force
    }
    catch{
       throw $_.Exception
    }
}
else{
   Write-Host "The MOM agent service $($momServiceName) not found on this server"
}
#-----------------
# Rename agent dir
#-----------------
if(test-path "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State"){
    write-output "MOM Agent dir found, renaming"
    cd "C:\Program Files\Microsoft Monitoring Agent\Agent"
    mv '.\Health Service State\' '.\Health Service State.old\'
    ls
} 
else{
    write-output "MOM agent dir not found"
}

#-------------------
# start the service
#-------------------
Get-Service -Name $momServiceName | start-Service -Verbose
Get-Service -Name $momServiceName

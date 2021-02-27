<#
.SYNOPSIS
   Installs chocolatey and choco packages on new Azure VM.
   Script will be executed via Azure Pipeline
#>


#--- Params
param(
    [string]$chocoPkg = "googlechrome"
)

# Insall ChocoLatey
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Refresh Env
RefreshEnv.cmd

# Install Packages
choco install $chocoPkg -y

# CleanUp choco for next installation
if ($env:ChocolateyInstall -and (Test-Path $env:ChocolateyInstall)) {
    Remove-Item -Path $env:ChocolateyInstall -Recurse -Force
}
if ($env:ChocolateyToolsLocation -and (Test-Path $env:ChocolateyToolsLocation)) {
    Remove-Item -Path $env:ChocolateyToolsLocation -Recurse -Force
}
foreach ($scope in 'User', 'Machine') {
    [Environment]::SetEnvironmentVariable('ChocolateyInstall', [string]::Empty, $scope)
}
foreach ($scope in 'User', 'Machine') {
    [Environment]::SetEnvironmentVariable('ChocolateyToolsLocation', [string]::Empty, $scope)
}

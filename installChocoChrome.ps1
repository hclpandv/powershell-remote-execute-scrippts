#---------------------------------------------
# How to Excute Remotely:
#    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/3ssg5jv'))
#---------------------------------------------

## Help : https://markheath.net/post/create-configure-vm-azure-cli

# Insall ChocoLatey
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Refresh Env
RefreshEnv.cmd

# Install chrome
choco install googlechrome -y

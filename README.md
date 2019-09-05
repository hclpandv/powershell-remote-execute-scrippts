# powershell-remote-execute-scripts

Collection of usable PS funtions which can be executed remotly from this repo itself.

* pre-requisites : You might need admin privilidges on the machine where you are executing

### How It works ?

1. Load the `vikiscripts.ps.funtions.ps1` script in your PowerShell session, use below command

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://bit.ly/2NnlJlS'))
```

2. Below new cmd-lets will be available for you

```
Get-HostEntries
Get-NetworkStatistics
Get-MsiDatabaseTable
Get-MyWifiPasswords
Save-XlsAsCSV
```

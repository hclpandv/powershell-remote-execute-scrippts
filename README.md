# powershell-remote-execute-scripts

Collection of usable PS scripts which can be executed remotly from this repo itself.

* pre-requisites : You might need admin privilidges and  on machine where you are executing

### How It works ?

1. Load the `vikiscripts.ps.funtions.ps1` script in your PowerShell session, use below command

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/hclpandv/powershell-remote-execute-scripts/master/vikiscripts.ps.funtions.ps1'))
```
2. Test

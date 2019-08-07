# powershell-remote-execute-scripts

Collection of usable PS scripts which can be executed remotly from this repo itself.

* pre-requisites : You might have admin privilidges and  on machine where you are executing

Example:

```powershell
iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/hclpandv/devops-cheatsheet/master/demo.ps1'))
```

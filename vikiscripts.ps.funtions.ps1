#-----------------------
# User Interface Element
#-----------------------

$Msg = @"
    Below Cmd-Lets are now available for you
    ----------------------------------------
    * Get-NetworkStatistics
    * Get-HostEntries
    * Get-MsiDatabaseTable
    * Save-XlsAsCSV
    * Get-MyWifiPasswords
    * Fake-MyPresence
    * VIM editor can be invoked from WSL (Use vi <file_path>)
"@

Write-Host "You are going to Install new PowerShell cmd-Lets provided by vikiscripts, it would take some time, please have patience" -ForegroundColor Green
Write-Host -ForegroundColor DarkCyan -Object $Msg
#-------------------------
# Function
#-------------------------
Function Get-NetworkStatistics 
{ 
    $properties = 'Protocol','LocalAddress','LocalPort' 
    $properties += 'RemoteAddress','RemotePort','State','ProcessName','PID'

    netstat -ano | Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object {

        $item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)

        if($item[1] -notmatch '^\[::') 
        {            
            if (($la = $item[1] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') 
            { 
               $localAddress = $la.IPAddressToString 
               $localPort = $item[1].split('\]:')[-1] 
            } 
            else 
            { 
                $localAddress = $item[1].split(':')[0] 
                $localPort = $item[1].split(':')[-1] 
            } 

            if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') 
            { 
               $remoteAddress = $ra.IPAddressToString 
               $remotePort = $item[2].split('\]:')[-1] 
            } 
            else 
            { 
               $remoteAddress = $item[2].split(':')[0] 
               $remotePort = $item[2].split(':')[-1] 
            } 

            New-Object PSObject -Property @{ 
                PID = $item[-1] 
                ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name 
                Protocol = $item[0] 
                LocalAddress = $localAddress 
                LocalPort = $localPort 
                RemoteAddress =$remoteAddress 
                RemotePort = $remotePort 
                State = if($item[0] -eq 'tcp') {$item[3]} else {$null} 
            } | Select-Object -Property $properties 
        } 
    } 
}

#-------------------------
# Function
#-------------------------
Function Get-HostEntries {
  Get-Content C:\Windows\System32\drivers\etc\hosts
}

#-------------------------
# Function
#-------------------------
#PowerShell Function to Get MSI Table. you can further export the table to csv

Function Get-MsiDatabaseTable () {
    <#     
    .SYNOPSIS     This function retrieves properties from a Windows Installer MSI database.     
    .DESCRIPTION     This function uses the WindowInstaller COM object to pull all values from the Property table from a MSI     
    .EXAMPLE     Get-MsiDatabaseProperties 'MSI_PATH'     
    .PARAMETER FilePath     The path to the MSI you'd like to query     
    #>
    [CmdletBinding()]
    param (
    [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='What is the path of the MSI you would like to query?')]
    [IO.FileInfo[]]$FilePath,
    [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Which MSI table you want to access?')]
    [string]$TableName
    )
 
    begin {
        $com_object = New-Object -com WindowsInstaller.Installer
    }
 
    process {
        try {
 
            $database = $com_object.GetType().InvokeMember(
                "OpenDatabase",
                "InvokeMethod",
                $Null,
                $com_object,
                @($FilePath.FullName, 0)
            )
 
            $query = "SELECT * FROM $TableName"
            $View = $database.GetType().InvokeMember(
                    "OpenView",
                    "InvokeMethod",
                    $Null,
                    $database,
                    ($query)
            )
 
            $View.GetType().InvokeMember("Execute", "InvokeMethod", $Null, $View, $Null)
 
            $record = $View.GetType().InvokeMember(
                    "Fetch",
                    "InvokeMethod",
                    $Null,
                    $View,
                    $Null
            )
 
            $msi_props = @{}
            while ($record -ne $null) {
                $prop_name = $record.GetType().InvokeMember("StringData", "GetProperty", $Null, $record, 1)
                $prop_value = $record.GetType().InvokeMember("StringData", "GetProperty", $Null, $record, 2)
                $msi_props[$prop_name] = $prop_value
                $record = $View.GetType().InvokeMember(
                    "Fetch",
                    "InvokeMethod",
                    $Null,
                    $View,
                    $Null
                )
            }
 
            $msi_props
 
        } catch {
            throw "Failed to get MSI file version the error was: {0}." -f $_
        }
    }
}

#Usage Below
#Get-MsiDatabaseTable -FilePath D:\2add14.msi -TableName "Directory"

#-------------------------
# Function
#-------------------------

Function Save-XlsAsCSV (){
    param (
    [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='What XLS file you would like to save-as csv?')]
    [IO.FileInfo[]]$XLSFilePath,
    [Parameter(Mandatory=$True,
        ValueFromPipeline=$True,
        ValueFromPipelineByPropertyName=$True,
        HelpMessage='Target path of CSV file?')]
    [string]$CSVFilePath
    )
    $E = New-Object -ComObject Excel.Application
    $E.Visible = $false
    $E.DisplayAlerts = $false
    $wb = $E.Workbooks.Open($XLSFilePath)
    foreach ($ws in $wb.Worksheets)
    {
        $n = $excelFile + "_" + $ws.Name
        $ws.SaveAs($CSVFilePath, 6)
    }
    $E.Quit()
}

#-------------------------
# Function
#-------------------------

Function Get-MyWifiPasswords (){
(netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)} | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize
}

#-------------------------
# Function
#-------------------------
Function vi ($File){
  write-host "If you have WSL Installed on your system, You can use VIM editor now"
  $File = $File -replace "\\", "/" -replace " ", "\ "
  bash -c "vi $File"
}

#-------------------------
# Function - MouseGiggle
#-------------------------
Function Fake-MyPresence{
  param($minutes = 120)

  $myshell = New-Object -com "Wscript.Shell"

  for ($i = 0; $i -lt $minutes; $i++) {
    Start-Sleep -Seconds 60
    $myshell.sendkeys(".")
  }
}

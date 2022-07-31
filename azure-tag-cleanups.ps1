Function Repair-AzureTags($resourceName,$resourceGroupName,$badKey,$correctKey){
   $target = Get-AzResource -ResourceGroupName $resourceGroupName -Name $resourceName
   $previousValue = $target.Tags.$badKey
   $target.Tags.Remove($badKey)
   $target.Tags.$correctKey = $previousValue
   $target | Set-AzResource -Tag $target.Tags -Force
}

Function Repair-AzureTags($oldKey,$newKey){
    $targets_resources = Get-AzResource | Where-Object{$_.Tags.Keys -match $oldKey} 
    $targets_resources | ForEach-Object {
        $OldKeyValue = $_.Tags.$oldKey
        $NewTag = @{$newKey=$OldKeyValue}
        $OldTag = @{$oldKey=$OldKeyValue}
        $resourceID = $_.ResourceId
        Update-AzTag -ResourceId $resourceID -Tag $NewTag -Operation Merge
        $Check = Get-AzResource -Id $resourceID | Where-Object {$_.Tags.Keys -match $newKey}
        if ($Check) {
            Update-AzTag -ResourceId $resourceID -Tag $OldTag -Operation Delete
        }
    }
}

Repair-AzureTags -oldKey Application_Owner -newKey ApplicationOwner

#--------------- Working 31st Aug 2022 

Function Rename-AzureTagKey(){
<#
 .SYNOPSIS
    Renames Tag Keys on multiple resources simnultaneously.
    Accepts objects from Pipeline
  .Example
    Get-AzResource -resourceGroupName TerraformStateRG | Rename-AzureTagKey -oldKey costcentre -newKey costcenter
#>
   [CmdletBinding()]
   param(
     [parameter(Mandatory=$true,ValueFromPipeline=$true)]
     $resource,
     [string]$oldKey,
     [string]$newKey   
   )
   process{
       if($resource.Tags.keys -eq $oldKey){
           $oldKeyValue = $resource.Tags.$oldKey
           $resource.Tags.Remove($oldKey)
           $resource.Tags.$newKey = $oldKeyValue
           $resource | Set-AzResource -Tag $resource.Tags -Force
       }
   }
}

Get-AzResource | Rename-AzureTagKey -oldKey Application_Owner -newKey ApplicationOwner


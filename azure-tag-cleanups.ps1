Function Repair-AzureTags($resourceName,$resourceGroupName,$badKey,$correctKey){
   $target = Get-AzResource -ResourceGroupName $resourceGroupName -Name $resourceName
   $previousValue = $target.Tags.$badKey
   $target.Tags.Remove($badKey)
   $target.Tags.$correctKey = $previousValue
   $target | Set-AzResource -Tag $target.Tags -Force
}

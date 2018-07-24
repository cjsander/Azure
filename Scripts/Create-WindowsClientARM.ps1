function New-RandomString {
    $String = $null
    $r = New-Object System.Random
    1..6 | % { $String += [char]$r.next(97,122) }
    $string
}

### Define variables

$SubscriptionName = 'Visual Studio'
$Location =  'Central US' ### Use "Get-AzureLocation | Where-Object Name -eq 'ResourceGroup' | Format-Table Name, LocationsString -Wrap" in ARM mode to find locations which support Resource Groups
$GroupName = 'test-lab'
$DeploymentName = 'client-deployment'
$PublicDNSName = 'test-lab-' + (New-RandomString)
$AdminUsername = 'test'

### Connect to Azure account

if (Get-AzureSubscription){
    Get-AzureSubscription -SubscriptionName $SubscriptionName | Select-AzureSubscription -Verbose
    }
    else {
    Add-AzureAccount
    Get-AzureSubscription -SubscriptionName $SubscriptionName | Select-AzureSubscription -Verbose
    }

Switch-AzureMode AzureResourceManager -Verbose

### Get Resource Group ###
$AzureResourceGroup = Get-AzureResourceGroup -Name $GroupName
Write-Host 'Resource Group Name is'$AzureResourceGroup.ResourceGroupName

### Get Storage Account ###
$AzureStorageAccount = ($AzureResourceGroup | Get-AzureStorageAccount).Name
Write-Host 'Storage Account is' $AzureStorageAccount

### Get Virtual Network ###
$AzureVirtualNetwork = ($AzureResourceGroup | Get-AzureVirtualNetwork).Name
Write-Host 'Virtual Network is' $AzureVirtualNetwork

$parameters = @{
    'StorageAccountName'="$AzureStorageAccount";
    'adminUsername'="$AdminUsername";
    'dnsNameForPublicIP'="$PublicDNSName";
    'virtualNetworkName'="$AzureVirtualNetwork"
    }

New-AzureResourceGroupDeployment `
    -Name $DeploymentName `
    -ResourceGroupName $AzureResourceGroup.ResourceGroupName `
    -StorageAccountNameFromTemplate $AzureStorageAccount `
    -TemplateFile WindowsClient.json `
    -TemplateParameterObject $parameters `
    -Verbose

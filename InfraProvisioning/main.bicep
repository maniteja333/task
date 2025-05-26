param virtualNetworkName string
param AkssubnetName string
param AppgwsubnetName string
param PlesubnetName string
param storageAccountName string 
param containerName string 


module VirtualNetworkModule './NetworkProvisioning/VirtualNetwork.bicep' = {
  name: 'NetworkDeployment'
  params: {
    virtualNetworkName: virtualNetworkName
    AkssubnetName: AkssubnetName
    AppgwsubnetName: AppgwsubnetName
    PlesubnetName: PlesubnetName
  }
}

module storageModule './templates/storageaccount.bicep' = {
  name: 'storageDeployment'
  params: {
    storageAccountName: storageAccountName
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    containerName: containerName
  }
}


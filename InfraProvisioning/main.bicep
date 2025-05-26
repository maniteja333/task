param virtualNetworkName string
param AkssubnetName string
param AppgwsubnetName string
param PlesubnetName string
param Plesubnetid string = '/subscriptions/58d256cb-83ad-4305-895e-3e58664a8daa/resourceGroups/randomapp-rg/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/ple-subnet'


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
   plesubnetid: Plesubnetid
  }
}


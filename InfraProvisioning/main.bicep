param virtualNetworkName string = 'aks-vnet'
param AkssubnetName string = 'aks-subnet'
param AppgwsubnetName string = 'appgw-subnet'


module VirtualNetworkModule './NetworkProvisioning/VirtualNetwork.bicep' = {
  name: 'NetworkDeployment'
  params: {
    virtualNetworkName: virtualNetworkName
    AkssubnetName: AkssubnetName
    AppgwsubnetName: AppgwsubnetName
  }
}

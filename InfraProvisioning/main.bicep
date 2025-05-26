param virtualNetworkName string
param AkssubnetName  string
param AppgwsubnetName string


module VirtualNetworkModule './NetworkProvisioning/Virtualnetwork.bicep' = {
  name: 'Networkdeployment'
  params: {
    virtualNetworkName: virtualNetworkName
    AkssubnetName: AkssubnetName
    AppgwsubnetName: AppgwsubnetName
  }
}

param virtualNetworkName string
param AkssubnetName string
param AppgwsubnetName string
param PlesubnetName string
param Plesubnetid string = '/subscriptions/58d256cb-83ad-4305-895e-3e58664a8daa/resourceGroups/randomapp-rg/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/ple-subnet'
param managedClusters_aks_cluster_name string = 'aks-cluster'

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

module AksModule './templates/aks.bicep' = {
  name: 'AksDeployment'
  params: {
     managedClusters_aks_cluster_name : managedClusters_aks_cluster_name
  }
}


param virtualNetworkName string
param AkssubnetName string
param AppgwsubnetName string
param PlesubnetName string
param Plesubnetid string = '/subscriptions/58d256cb-83ad-4305-895e-3e58664a8daa/resourceGroups/randomapp-rg/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/ple-subnet'
param managedClusters_aks_cluster_name string = 'aks-cluster'

param applicationGateways_appgw_name string = 'appgw'
param appgwip string = 'appgwip'
param appgwSubnetID string = '/subscriptions/58d256cb-83ad-4305-895e-3e58664a8daa/resourceGroups/randomapp-rg/providers/Microsoft.Network/virtualNetworks/aks-vnet/subnets/appgw-subnet'
param appgwumi string = 'appgw-umi'
param appgwkeyvault string ='keyvault-ra'
param sslcertname string = 'appgw2'
param frontendfqdn string 

@secure()
param windowsAdminPassword string
param acrName string 

module VirtualNetworkModule './NetworkProvisioning/VirtualNetwork.bicep' = {
  name: 'NetworkDeployment'
  params: {
    virtualNetworkName: virtualNetworkName
    AkssubnetName: AkssubnetName
    AppgwsubnetName: AppgwsubnetName
    PlesubnetName: PlesubnetName
  }
}

// module storageModule './templates/storageaccount.bicep' = {
//   name: 'storageDeployment'
//   params: {
//    plesubnetid: Plesubnetid
//   }
// }

module AksModule './templates/aks.bicep' = {
  name: 'AksDeployment'
  params: {
     managedClusters_aks_cluster_name : managedClusters_aks_cluster_name
     windowsAdminPassword : windowsAdminPassword
     acrName:acrName
  }
}

module AcrModule './templates/acr.bicep' = {
  name: 'AcrDeployment'
  params: {
     acrName: acrName
  }
}

module AppGEModule './templates/appgateway.bicep' = {
  name: 'AppgatewayDeployment'
  params: {
     applicationGateways_appgw_name : applicationGateways_appgw_name
      appgwip :appgwip
      appgwSubnetID :appgwSubnetID 
      appgwumi :appgwumi
      appgwkeyvault :appgwkeyvault 
      sslcertname : sslcertname 
      frontendfqdn :frontendfqdn
        }
}


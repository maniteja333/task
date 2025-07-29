param virtualNetworkName string
param AkssubnetName string
param AppgwsubnetName string
param PlesubnetName string
// param Plesubnetid string 
// param managedClusters_aks_cluster_name string
param storageAccountName string 
// param applicationGateways_appgw_name string
// param appgwip string
// param appgwSubnetID string 
// param appgwumi string 
// param appgwkeyvault string 
// param sslcertname string 
// param frontendfqdn string 
// param umiName string 
// @secure()
// param windowsAdminPassword string
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

 module storageModule './templates/storageaccount.bicep' = {
   name: 'storageDeployment'
   params: {
    // plesubnetid: Plesubnetid
    storageAccountName:  storageAccountName
   }
 }

// module AksModule './templates/aks.bicep' = {
//   name: 'AksDeployment'
//   params: {
//      managedClusters_aks_cluster_name : managedClusters_aks_cluster_name
//      windowsAdminPassword : windowsAdminPassword
//      acrName:acrName
//   }
// }

module AcrModule './templates/acr.bicep' = {
  name: 'AcrDeployment'
  params: {
     acrName: acrName
  }
}

// module AppGEModule './templates/appgateway.bicep' = {
//   name: 'AppgatewayDeployment'
//   params: {
//      applicationGateways_appgw_name : applicationGateways_appgw_name
//       appgwip :appgwip
//       appgwSubnetID :appgwSubnetID 
//       appgwumi :appgwumi
//       appgwkeyvault :appgwkeyvault 
//       sslcertname : sslcertname 
//       frontendfqdn :frontendfqdn
//         }
// }

// module Umi './templates/umi.bicep' = {
//   name: 'UmiDeployment'
//   params: {
//       umiName : umiName
//   }
// }

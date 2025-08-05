param location string = resourceGroup().location
param virtualNetworkName string
param AkssubnetName  string
param AppgwsubnetName string
param PlesubnetName string

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }

  resource subnet1 'subnets' = {
    name: AkssubnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
        }  }

  resource subnet2 'subnets' = {
    name: AppgwsubnetName
    properties: {
      addressPrefix: '10.0.1.0/24'
    }    
  }
  resource subnet3 'subnets' = {
    name: PlesubnetName
    properties: {
      addressPrefix: '10.0.2.0/24'
    }    
  }
}

resource virtualNetworks_aks_vnet_name_null 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2024-07-01' = {
  parent: virtualNetwork
  name: 'null'
  properties: {
    peeringState: 'Connected'
    peeringSyncLevel: 'FullyInSync'
    remoteVirtualNetwork: {
      id: '/subscriptions/20e67141-3faf-491a-bb15-d9df98bb8021/resourceGroups/sa-rg/providers/Microsoft.Network/virtualNetworks/appgw2'

    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: false
    allowGatewayTransit: false
    useRemoteGateways: false
    doNotVerifyRemoteGateways: false
    peerCompleteVnets: true
    remoteAddressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    remoteVirtualNetworkAddressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
  }
  dependsOn: [
    virtualNetwork 
  ]
}



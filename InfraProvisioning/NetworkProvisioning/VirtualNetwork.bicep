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


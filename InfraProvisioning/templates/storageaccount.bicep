param storageAccountName string = 'frontendsa433'
param location string = resourceGroup().location
param plesubnetid string

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: 'northeurope'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Enabled'
    allowCrossTenantReplication: false
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    largeFileSharesState: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      requireInfrastructureEncryption: false
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccounts_blob 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  parent: storageAccount
  name: 'default'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      allowPermanentDelete: false
      enabled: false
    }
  }
}

// resource Microsoft_Storage_storageAccounts_fileServices_storageAccounts_frontend433_name_default 'Microsoft.Storage/storageAccounts/fileServices@2024-01-01' = {
//   parent: storageAccounts_frontend433_name_resource
//   name: 'default'
//   sku: {
//     name: 'Standard_LRS'
//     tier: 'Standard'
//   }
//   properties: {
//     protocolSettings: {
//       smb: {}
//     }
//     cors: {
//       corsRules: []
//     }
//     shareDeleteRetentionPolicy: {
//       enabled: false
//       days: 0
//     }
//   }
// }

// resource Microsoft_Storage_storageAccounts_queueServices_storageAccounts_frontend433_name_default 'Microsoft.Storage/storageAccounts/queueServices@2024-01-01' = {
//   parent: storageAccounts_frontend433_name_resource
//   name: 'default'
//   properties: {
//     cors: {
//       corsRules: []
//     }
//   }
// }

// resource Microsoft_Storage_storageAccounts_tableServices_storageAccounts_frontend433_name_default 'Microsoft.Storage/storageAccounts/tableServices@2024-01-01' = {
//   parent: storageAccounts_frontend433_name_resource
//   name: 'default'
//   properties: {
//     cors: {
//       corsRules: []
//     }
//   }
// }

resource storageAccounts_web 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  parent: storageAccounts_blob
  name: '$web'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccount
  ]
}

// Private Endpoint for `web` (static website)
resource webPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: '${storageAccountName}-web-pe'
  location: location
  properties: {
    subnet: {
      id: plesubnetid
    }
    privateLinkServiceConnections: [
      {
        name: 'webConnection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: [
            'web'
          ]
        }
      }
    ]
  }
}

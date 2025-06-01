param storageAccountName string = 'frontendsa433'
param location string = resourceGroup().location
param plesubnetid string

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    dnsEndpointType: 'Standard'
    defaultToOAuthAuthentication: false
    publicNetworkAccess: 'Disabled'
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
}

// Enable static website (required for 'web' group in private endpoint)
resource staticWebsite 'Microsoft.Storage/storageAccounts/staticWebsite@2024-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    indexDocument: 'index.html'
    error404Document: '404.html'
  }
}

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
  dependsOn: [
    staticWebsite
  ]
}

resource ple_dns_zone 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-05-01' = {
  parent: webPrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink_web_core_windows_net'
        properties: {
          privateDnsZoneId: resourceId('Microsoft.Network/privateDnsZones', 'privatelink.web.core.windows.net')
        }
      }
    ]
  }
  dependsOn: [
    webPrivateEndpoint
  ]
}

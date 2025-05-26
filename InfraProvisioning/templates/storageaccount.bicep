param storageAccountName string
param location string = resourceGroup().location
param skuName string 
param kind string 
param accessTier string 
param containerName string
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    accessTier: accessTier
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2024-01-01' = {
  name: 'default'
  parent: storageAccount
}

resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: containerName
  parent: blobService
  properties: {
    publicAccess: 'None'  // Change to 'Blob' or 'Container' if needed
  }
}

resource staticWebsite 'Microsoft.Storage/storageAccounts/blobServices/staticWebsite@2023-01-01' = {
  name: 'default'
  parent: blobService
  properties: {
    enabled: true
    indexDocument: 'index.html'
    error404Document: '404.html'
  }
}



output storageAccountId string = storageAccount.id
output primaryEndpoint string = storageAccount.properties.primaryEndpoints.blob

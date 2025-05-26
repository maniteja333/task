param acrName string 
param location string = resourceGroup().location


resource acr 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Standard'  // Can be Basic, Standard, or Premium
  }
  properties: {
    adminUserEnabled: false
  }
}

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(acr.id, aksClusterName, 'AcrPull')
//   scope: acr
//   properties: {
//     roleDefinitionId: '/subscriptions/<subscription-id>/providers/Microsoft.Authorization/roleDefinitions/acrpull'
//     principalId: aksClusterName
//   }
// }

param umiName string 

resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2025-01-31-preview' = {
  name: umiName
  location: 'northeurope'
}

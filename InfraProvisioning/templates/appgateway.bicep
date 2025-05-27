param applicationGateways_appgw_name string
param appgwip string
param appgwSubnetID string
param appgwumi string
param appgwkeyvault string
param sslcertname string
param frontendfqdn string

resource Pip 'Microsoft.Network/publicIPAddresses@2024-05-01' existing = {
  name: appgwip
}

resource appgw_umi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: appgwumi
}

resource appgw_keyvault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  
  name: appgwkeyvault

}


resource applicationGateways_appgw_name_resource 'Microsoft.Network/applicationGateways@2024-05-01' = {
  name: applicationGateways_appgw_name
  location: 'northeurope'
  zones: [ '1', '2', '3' ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
     '${appgw_umi.id}' :{}
    }
  }
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
      family: 'Generation_1'
      capacity: 1
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: appgwSubnetID
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: applicationGateways_appgw_name
        properties: {}
      }
      {
        name: sslcertname
        properties: {
          keyVaultSecretId: '${appgw_keyvault.properties.vaultUri}secrets/${sslcertname}'

        }
      }
    ]
    trustedRootCertificates: []
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIpIPv4'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: Pip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'FE'
        properties: {
          backendAddresses: [
            {
              fqdn: frontendfqdn
            }
          ]
        }
      }
      {
        name: 'api'
        properties: {
          backendAddresses: [
            {
              ipAddress: '10.0.0.5'
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: 'FE'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGateways_appgw_name, 'FE-Probe')
          }
        }
      }
      {
        name: 'api-be'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          requestTimeout: 20
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGateways_appgw_name, 'api-probe')
          }
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGateways_appgw_name, 'appGwPublicFrontendIpIPv4')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGateways_appgw_name, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGateways_appgw_name, sslcertname)
          }
          hostNames: []
          requireServerNameIndication: false
          customErrorConfigurations: []
        }
      }
    ]
    listeners: []
    urlPathMaps: [
      {
        name: 'fe'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateways_appgw_name, 'FE')
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateways_appgw_name, 'FE')
          }
          pathRules: [
            {
              name: 'FE'
              properties: {
                paths: [ '/*' ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateways_appgw_name, 'FE')
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateways_appgw_name, 'FE')
                }
              }
            }
            {
              name: 'BE'
              properties: {
                paths: [ '/generate' ]
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGateways_appgw_name, 'api')
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGateways_appgw_name, 'api-be')
                }
              }
            }
          ]
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'fe'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGateways_appgw_name, 'https')
          }
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', applicationGateways_appgw_name, 'fe')
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: 'FE-probe'
        properties: {
          protocol: 'Https'
          host: frontendfqdn
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: false
          minServers: 0
          match: {
            statusCodes: [ '200-399' ]
          }
        }
      }
      {
        name: 'api-probe'
        properties: {
          protocol: 'Http'
          path: '/generate'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [ '200-399' ]
          }
        }
      }
    ]
    rewriteRuleSets: []
    redirectConfigurations: []
    privateLinkConfigurations: []
    enableHttp2: true
  }
}

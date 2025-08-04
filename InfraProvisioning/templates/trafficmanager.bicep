param trafficManagerName string

resource trafficManagerProfiles 'Microsoft.Network/trafficManagerProfiles@2022-04-01' = {
  name: trafficManagerName
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Weighted'
    dnsConfig: {
      relativeName: trafficManagerName
      ttl: 60
    }
    monitorConfig: {
      profileMonitorStatus: 'Degraded'
      protocol: 'HTTP'
      port: 80
      path: '/'
      intervalInSeconds: 30
      toleratedNumberOfFailures: 3
      timeoutInSeconds: 10
    }
    endpoints: [
          {
            name: 'appgw1'
            type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
            properties: {
              endpointStatus: 'Enabled'
              target: '4.209.240.40'
              weight: 50
              endpointLocation: 'Australia Central'
              alwaysServe:'Disabled'
            }
          }
         {
        name: 'appgw2'
        type: 'Microsoft.Network/trafficManagerProfiles/externalEndpoints'
        properties: {
          endpointStatus: 'Enabled'
          endpointMonitorStatus: 'Degraded'
          target: '98.64.98.244'
          weight: 50
          priority: 2
          endpointLocation: 'Australia Central'
          alwaysServe: 'Disabled'
        }
      }
          
        ]
    trafficViewEnrollmentStatus: 'Disabled'
    maxReturn: 0
  }
}

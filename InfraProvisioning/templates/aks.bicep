param managedClusters_aks_cluster_name string 
param acrName string
@secure()
param windowsAdminPassword string 

param virtualNetworks_aks_vnet_externalid string = '/subscriptions/20e67141-3faf-491a-bb15-d9df98bb8021/resourceGroups/sa-rg/providers/Microsoft.Network/virtualNetworks/aks-vnet'
param adminuser string  = 'adminuser'

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

resource aks 'Microsoft.ContainerService/managedClusters@2025-02-01' = {
  name: managedClusters_aks_cluster_name
  location: 'northeurope'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: '1.31.8'
    dnsPrefix: '${managedClusters_aks_cluster_name}-dns'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        vmSize: 'Standard_D2ads_v6'
        osDiskSizeGB: 128
        osDiskType: 'Managed'
        kubeletDiskType: 'OS'
        vnetSubnetID: '${virtualNetworks_aks_vnet_externalid}/subnets/aks-subnet'
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        maxCount: 2
        minCount: 1
        enableAutoScaling: true
        scaleDownMode: 'Delete'
        powerState: {
          code: 'Running'
        }
        enableNodePublicIP: false
        mode: 'System'
        osType: 'Linux'
        osSKU: 'Ubuntu'
        upgradeSettings: {
          maxSurge: '10%'
        }
        enableFIPS: false
        securityProfile: {
          enableVTPM: false
          enableSecureBoot: false
        }
      }
    ]
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      networkPolicy: 'none'
      networkDataplane: 'azure'
      loadBalancerSku: 'Standard'
      loadBalancerProfile: {
        managedOutboundIPs: {
          count: 1
        }
        backendPoolType: 'nodeIPConfiguration'
      }
      podCidr: '10.244.0.0/16'
      serviceCidr: '10.1.0.0/16'
      dnsServiceIP: '10.1.0.10'
      outboundType: 'loadBalancer'
      ipFamilies: [
        'IPv4'
      ]
    }

    }
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
      nodeOSUpgradeChannel: 'NodeImage'
    }
    disableLocalAccounts: false
    securityProfile: {
      imageCleaner: {
        enabled: true
        intervalHours: 168
      }
      workloadIdentity: {
        enabled: true
      }
    }
    storageProfile: {
      diskCSIDriver: {
        enabled: true
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
    oidcIssuerProfile: {
      enabled: true
    }
    metricsProfile: {
      costAnalysis: {
        enabled: false
      }
    }
    bootstrapProfile: {
      artifactSource: 'Direct'
    }
    nodeResourceGroup: 'MC_randomapp-rg_${managedClusters_aks_cluster_name}_northeurope'
    supportPlan: 'KubernetesOfficial'
  }
}



resource aksManagedNodeOSUpgradeSchedule 'Microsoft.ContainerService/managedClusters/maintenanceConfigurations@2025-02-01' = {
  parent: aks
  name: 'aksManagedNodeOSUpgradeSchedule'
  properties: {
    maintenanceWindow: {
      schedule: {
        weekly: {
          intervalWeeks: 1
          dayOfWeek: 'Sunday'
        }
      }
      durationHours: 8
      utcOffset: '+00:00'
      startDate: '2025-08-03'
      startTime: '00:00'
    }
  }
}

// resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(aks.id, acr.id, 'acrpull-role')
//   scope: acr
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
//     principalId: aks.identity.principalId
//   }
//   dependsOn: [
//     aks
//   ]
// }

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.33.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Existing ACR (for pull access)
data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.aks_cluster_name}-dns"

  default_node_pool {
    name                    = "agentpool"
    vm_size                 = var.node_vm_size
    auto_scaling_enabled    = true
    min_count               = var.node_pool_min_count
    max_count               = var.node_pool_max_count
    orchestrator_version    = var.k8s_version
    os_disk_size_gb         = 128
    os_disk_type            = "Managed"
    max_pods                = 30
    type                    = "VirtualMachineScaleSets"
    kubelet_disk_type       = "OS"
    upgrade_settings {
      max_surge = "10%"
    }
    node_public_ip_enabled = false
    os_sku                 = "Ubuntu"
    scale_down_mode        = "Delete"
    vnet_subnet_id         = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  kubernetes_version = var.k8s_version

  role_based_access_control_enabled = true

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"

    pod_cidr        = "10.244.0.0/16"
    service_cidr    = "10.1.0.0/16"
    dns_service_ip  = "10.1.0.10"
    ip_versions     = ["IPv4"]

    load_balancer_profile {
      backend_pool_type         = "NodeIPConfiguration"
      managed_outbound_ip_count = 1
    }
  }

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 168

  windows_profile {
    admin_username = var.windows_admin_username
    admin_password = var.windows_admin_password
  }

  lifecycle {
    ignore_changes = [
      kube_admin_config_raw,
      kube_config_raw
    ]
  }

  # Advanced autoscaler profile (mirroring your existing settings)
  auto_scaler_profile {
    balance_similar_node_groups                   = false
    daemonset_eviction_for_empty_nodes_enabled    = false
    daemonset_eviction_for_occupied_nodes_enabled = true
    empty_bulk_delete_max                        = "10"
    expander                                      = "random"
    ignore_daemonsets_utilization_enabled         = false
    max_graceful_termination_sec                  = "600"
    max_node_provisioning_time                    = "15m"
    max_unready_nodes                             = 3
    max_unready_percentage                        = 45
    new_pod_scale_up_delay                        = "0s"
    scale_down_delay_after_add                    = "10m"
    scale_down_delay_after_delete                 = "10s"
    scale_down_delay_after_failure                = "3m"
    scale_down_unneeded                           = "10m"
    scale_down_unready                            = "20m"
    scale_down_utilization_threshold              = "0.5"
    scan_interval                                 = "10s"
    skip_nodes_with_local_storage                 = false
    skip_nodes_with_system_pods                   = true
  }
}

# Give the AKS system-assigned identity AcrPull on the ACR
resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

output "kube_admin_config_raw" {
  description = "Admin kubeconfig (raw)"
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive   = true
}

output "kube_user_config_raw" {
  description = "User kubeconfig (raw)"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

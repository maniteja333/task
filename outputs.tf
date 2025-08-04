output "kube_admin_config" {
  description = "Kubeconfig for admin access"
  value       = azurerm_kubernetes_cluster.aks.kube_admin_config_raw
  sensitive   = true
}

output "kube_user_config" {
  description = "Kubeconfig for user access"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_cluster_resource_id" {
  value = azurerm_kubernetes_cluster.aks.id
}
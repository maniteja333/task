variable "subscription_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "aks_cluster_name" {
  type = string
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2ads_v6"
}

variable "node_pool_min_count" {
  type    = number
  default = 1
}

variable "node_pool_max_count" {
  type    = number
  default = 2
}

variable "k8s_version" {
  type    = string
  default = "1.31.8"
}

variable "subnet_id" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "windows_admin_username" {
  type    = string
  default = "adminuser"
}

variable "windows_admin_password" {
  type      = string
  sensitive = true
}
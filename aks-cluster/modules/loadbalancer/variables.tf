variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "vnet_id" {
  description = "ID of the VNET where AKS is deployed"
  type        = string
}

variable "aks_nic_name" {
  description = "Name of the AKS node network interface"
  type        = string
}

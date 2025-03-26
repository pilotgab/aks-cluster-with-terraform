variable "resource_group_name" {
  description = "Resource group for the load balancer"
  type        = string
}

variable "location" {
  description = "Location for the load balancer"
  type        = string
}

variable "cluster_name" {
  description = "The AKS cluster name for tagging or naming"
  type        = string
}

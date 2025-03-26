variable "location" {
}

variable "resource_group_name" {}

variable "service_principal_name" {
  type = string
}

variable "ssh_public_key" {
  description = "ssh public key for the cluster"
  type = string

}


variable "node_pool_name" {

}
variable "cluster_name" {

}

variable "subnet_ids" {
  description = "List of private subnet IDs for the AKS cluster"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
}

variable "node_pool_name" {
  description = "AKS node pool name"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for Linux nodes in AKS"
  type        = string
}

variable "client_id" {
  description = "Service principal client ID"
  type        = string
}

variable "client_secret" {
  description = "Service principal client secret"
  type        = string
}

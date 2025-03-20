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

variable "client_id" {}
variable "client_secret" {
  type = string
  sensitive = true
}

variable "node_pool_name" {

}
variable "cluster_name" {

}

variable "subnet_ids" {
  description = "List of private subnet IDs for the AKS cluster"
  type        = list(string)
}

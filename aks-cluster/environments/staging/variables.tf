variable "rgname" {
  type        = string
  description = "resource group name"
}

variable "location" {
  type    = string
  default = "cannadacentral"
}

variable "service_principal_name" {
  type = string
}

variable "keyvault_name" {
  type = string
}

variable "SUB_ID" {
  type = string
}

variable "node_pool_name" {

}

variable "cluster_name" {

}

variable "ssh_public_key" {
  description = "ssh public key for the cluster"
  type        = string
}

variable "address_space" {
  type        = string
  description = "VNet CIDR block"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDRs"
}

variable "name" {
  type        = string
  description = "Prefix name for resources"
}

# variable "firewall_subnet_cidr" {
#   description = "CIDR for Azure Firewall subnet"
#   type        = string
# }

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# variable "firewall_dns_servers" {
#   description = "List of DNS servers for the firewall policy"
#   type        = list(string)
# }

# variable "threat_intel_mode" {
#   description = "The threat intelligence mode for the firewall policy"
#   type        = string
#   default     = "Alert"
# }

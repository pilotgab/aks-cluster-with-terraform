variable "rgname" {
  type        = string
  description = "resource group name"
}

variable "location" {
  type    = string
  default = "canadacentral"
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

variable "lb_frontend_port" {
  description = "Frontend port for load balancer rule"
  type        = number
  default     = 80
}

variable "lb_backend_port" {
  description = "Backend port for load balancer rule"
  type        = number
  default     = 80
}

variable "lb_probe_port" {
  description = "Port used by load balancer probe"
  type        = number
  default     = 80
}

variable "lb_protocol" {
  description = "Protocol for load balancer rules and probe"
  type        = string
  default     = "Tcp"
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "node_pool_name" {
  description = "Name of the AKS node pool"
  type        = string
}


variable "client_id" {
  description = "Service principal client ID (can be provided or fetched from ServicePrincipal module)"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "Service principal client secret (can be provided or fetched from ServicePrincipal module)"
  type        = string
  default     = ""
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

variable "name" {
  description = "Prefix for all resources"
  type        = string
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "address_space" {
  type        = string
  description = "CIDR for the virtual network"
}

variable "firewall_subnet_cidr" {
  description = "CIDR for Azure Firewall subnet"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for flow logs"
  type        = string
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "List of public subnet CIDR ranges"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "List of private subnet CIDR ranges"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "zones" {
  description = "List of availability zones for zone-redundant public IPs"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "firewall_dns_servers" {
  description = "List of DNS servers for Azure Firewall"
  type        = list(string)
  default     = []
}

variable "threat_intel_mode" {
  description = "Threat intelligence mode for firewall policy (Off, Alert, or Deny)"
  type        = string
  default     = "Alert"
}

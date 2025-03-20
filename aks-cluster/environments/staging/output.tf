output "resource_group_name" {
  value = azurerm_resource_group.rg1.name
}

output "client_id" {
  description = "The application id of AzureAD application created."
  value       = module.ServicePrincipal.client_id
}

output "client_secret" {
  description = "Password for service principal."
  value       = module.ServicePrincipal.client_secret
  sensitive = true

}


# outputs.tf (root)
output "vnet_id" {
  value = module.vnet.vnet_id
}

output "public_subnets" {
  value = module.vnet.public_subnets
}

output "private_subnets" {
  value = module.vnet.private_subnets
}

output "firewall_ip" {
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
  description = "The private IP of the Azure Firewall"
}

output "public_nat_ip" {
  value       = azurerm_public_ip.nat.ip_address
  description = "The public IP for NAT gateway"
}

output "firewall_policy_id" {
  value       = azurerm_firewall_policy.this.id
  description = "Firewall policy resource ID"
}

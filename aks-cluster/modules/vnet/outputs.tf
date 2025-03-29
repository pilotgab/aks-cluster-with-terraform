output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "public_subnets" {
  value = azurerm_subnet.public[*].id
}

output "private_subnets" {
  value = azurerm_subnet.private[*].id
}

output "nat_gateway_id" {
  value = azurerm_nat_gateway.this.id
}

# output "firewall_id" {
#   value = azurerm_firewall.this.id
# }

# output "firewall_private_ip" {
#   value = azurerm_firewall.this.ip_configuration[0].private_ip_address
# }

output "network_watcher_flow_log_ids" {
  description = "Map of network watcher flow log IDs by NSG (private/public)"
  value       = { for key, flow_log in azurerm_network_watcher_flow_log.this : key => flow_log.id }
}

output "nat_public_ip" {
  value = azurerm_nat_gateway.nat.public_ip_address
}

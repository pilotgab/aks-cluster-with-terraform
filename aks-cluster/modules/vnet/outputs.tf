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

output "load_balancer_name" {
  description = "Name of the custom load balancer"
  value       = azurerm_lb.aks_custom_lb.name
}

output "load_balancer_frontend_ip" {
  description = "Public IP address of the custom load balancer frontend"
  value       = azurerm_public_ip.aks_lb_public_ip.ip_address
}

output "load_balancer_backend_pool_id" {
  description = "ID of the backend pool for the custom load balancer"
  value       = azurerm_lb_backend_address_pool.aks_backend_pool.id
}

output "load_balancer_probe_id" {
  description = "ID of the health probe used by the load balancer"
  value       = azurerm_lb_probe.aks_http_probe.id
}

output "load_balancer_rule_id" {
  description = "ID of the load balancer rule for HTTP traffic"
  value       = azurerm_lb_rule.aks_http_rule.id
}

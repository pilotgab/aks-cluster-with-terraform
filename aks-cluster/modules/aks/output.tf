output "config" {
    value = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw

}

output "aks_lb_public_ip" {
  description = "Public IP address of the custom load balancer used by AKS outbound traffic"
  value       = azurerm_public_ip.aks_lb_public_ip.ip_address
}

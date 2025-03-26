output "config" {
    value = azurerm_kubernetes_cluster.aks-cluster.kube_config_raw

}

output "node_resource_group" {
  description = "The resource group created for the AKS nodes"
  value       = azurerm_kubernetes_cluster.aks-cluster.node_resource_group
}

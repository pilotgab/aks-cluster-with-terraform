

# CREATE PUBLIC IP FOR CUSTOM LB
resource "azurerm_public_ip" "aks_lb_public_ip" {
  name                = "${var.cluster_name}-custom-lb-pip"
  location            = var.location
  resource_group_name = "${var.resource_group_name}-nrg"
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [azurerm_kubernetes_cluster.aks-cluster]
}

# CREATE CUSTOM LOAD BALANCER
resource "azurerm_lb" "aks_custom_lb" {
  name                = "${var.cluster_name}-custom-lb"
  location            = var.location
  resource_group_name = "${var.resource_group_name}-nrg"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.aks_lb_public_ip.id
  }
}

# BACKEND ADDRESS POOL
resource "azurerm_lb_backend_address_pool" "aks_backend_pool" {
  name            = "aks-backend-pool"
  loadbalancer_id = azurerm_lb.aks_custom_lb.id
}

# HEALTH PROBE
resource "azurerm_lb_probe" "aks_http_probe" {
  name                = "http-probe"
  loadbalancer_id     = azurerm_lb.aks_custom_lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  number_of_probes    = 2
}

# LOAD BALANCING RULE
resource "azurerm_lb_rule" "aks_http_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.aks_custom_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.aks_backend_pool.id]
  probe_id                       = azurerm_lb_probe.aks_http_probe.id
}

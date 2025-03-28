# Public IP for Load Balancer
resource "azurerm_public_ip" "aks_lb_public_ip" {
  name                = "${var.cluster_name}-custom-lb-pip"
  location            = var.location
  resource_group_name = "${var.resource_group_name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Load Balancer
resource "azurerm_lb" "aks_custom_lb" {
  name                = "${var.cluster_name}-custom-lb"
  location            = var.location
  resource_group_name = "${var.resource_group_name}"
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "LoadBalancerFrontEnd"
    public_ip_address_id = azurerm_public_ip.aks_lb_public_ip.id
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "aks_backend_pool" {
  name            = "aks-backend-pool"
  loadbalancer_id = azurerm_lb.aks_custom_lb.id
}

# Health Probe - HTTP (for 200 status code checks)
resource "azurerm_lb_probe" "aks_http_probe" {
  name                = "http-health-probe"
  loadbalancer_id     = azurerm_lb.aks_custom_lb.id
  protocol            = "Http"
  port                = 8000
  request_path        = "/ping"
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load Balancing Rule for HTTP
resource "azurerm_lb_rule" "aks_http_rule" {
  name                           = "http-rule"
  loadbalancer_id                = azurerm_lb.aks_custom_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 8000
  frontend_ip_configuration_name = "LoadBalancerFrontEnd"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.aks_backend_pool.id]
  probe_id                       = azurerm_lb_probe.aks_http_probe.id
}

# Get the AKS node resource group
data "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  resource_group_name = var.aks_resource_group_name
}


resource "azurerm_lb_backend_address_pool_address" "aks_vmss" {
  name                    = "${var.cluster_name}-vmss"
  backend_address_pool_id = azurerm_lb_backend_address_pool.aks_backend_pool.id
  virtual_network_id      = var.vnet_id
  ip_address              = cidrhost(var.aks_subnet_cidr, 10)

  depends_on = [
    azurerm_lb.aks_custom_lb,
    azurerm_lb_backend_address_pool.aks_backend_pool
  ]
}

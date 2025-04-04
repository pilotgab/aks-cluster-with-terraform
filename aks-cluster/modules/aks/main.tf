# Datasource to get Latest Azure AKS latest Version
# Check if there is a var with the version name , if not , use the
# latest version, if there is a var, use that version
# make sure the version specified in var is valid

data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
  include_preview = false
}


resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                  = var.cluster_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  dns_prefix            = "${var.resource_group_name}-cluster"
  kubernetes_version    =  data.azurerm_kubernetes_service_versions.current.latest_version
  node_resource_group   = "${var.resource_group_name}-nrg"
  default_node_pool {
    name       = var.node_pool_name
    vm_size    = "Standard_D2s_v3"
    zones   = [1, 2, 3]
    auto_scaling_enabled = true
    max_count            = 2
    min_count            = 2
    os_disk_size_gb      = 30
    type                 = "VirtualMachineScaleSets"
    vnet_subnet_id       = var.subnet_ids[0]



  }

  service_principal  {
    client_id = var.client_id
    client_secret = var.client_secret
  }

 # to do: generate the ssh keys using tls_private_key
 # upload the key to key vault

  linux_profile {
    admin_username = "ubuntu"
    ssh_key {
      key_data = trimspace(var.ssh_public_key)
    }
  }


  network_profile {
    network_plugin     = "azure"
    load_balancer_sku  = "standard"
    outbound_type      = "userDefinedRouting"

    nat_gateway_profile {
      idle_timeout_in_minutes = 4
    }
    service_cidr   = "10.250.0.0/16"
    dns_service_ip = "10.250.0.10"
  }

}

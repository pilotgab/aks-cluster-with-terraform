data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "this" {
  name                = "${var.name}-vnet"
  address_space       = [var.address_space]
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = var.tags
}

resource "azurerm_subnet" "public" {
  count                = length(var.public_subnet_cidrs)
  name                 = "${var.name}-public-subnet-${count.index + 1}"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.public_subnet_cidrs[count.index]]
}

resource "azurerm_subnet" "private" {
  count                = length(var.private_subnet_cidrs)
  name                 = "${var.name}-private-subnet-${count.index + 1}"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.private_subnet_cidrs[count.index]]

  service_endpoints = ["Microsoft.ContainerRegistry","Microsoft.Storage","Microsoft.KeyVault"]
  delegation {
    name = "aks-delegation"
    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}


resource "azurerm_public_ip" "nat" {
  name                = "${var.name}-nat-ip"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_nat_gateway" "this" {
  name                = "${var.name}-nat-gateway"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = azurerm_subnet.private[count.index].id
  nat_gateway_id = azurerm_nat_gateway.this.id
}

resource "azurerm_route_table" "public" {
  name                = "${var.name}-public-rt"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = var.tags

  route {
    name           = "DefaultRoute"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}


resource "azurerm_route_table" "private" {
  name                = "${var.name}-private-rt"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  route {
    name           = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = azurerm_subnet.private[count.index].id
  route_table_id = azurerm_route_table.private.id
}

resource "azurerm_subnet_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = azurerm_subnet.public[count.index].id
  route_table_id = azurerm_route_table.public.id
}

resource "azurerm_network_security_group" "public" {
  name                = "${var.name}-public-nsg"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = var.tags

  security_rule {
    name                       = "AllowInternetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowInternetInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    security_rule {
    name                       = "AllowLbHealthProbes"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAllOutbound"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }


}



resource "azurerm_network_security_group" "private" {
  name                = "${var.name}-private-nsg"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  tags                = var.tags

  security_rule {
    name                       = "DenyInboundInternet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowLbHealthProbes"
    priority                   = 105
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }



  security_rule {
    name                       = "AllowNodePortRange"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }


  # Metrics Endpoint
  security_rule {
    name                       = "AllowMetricsScraping"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9100"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowOutboundInternet"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }




}

resource "azurerm_subnet_network_security_group_association" "public" {
  count                     = length(var.public_subnet_cidrs)
  subnet_id                 = azurerm_subnet.public[count.index].id
  network_security_group_id = azurerm_network_security_group.public.id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  count                     = length(var.private_subnet_cidrs)
  subnet_id                 = azurerm_subnet.private[count.index].id
  network_security_group_id = azurerm_network_security_group.private.id
}

# Firewall setup commented out

# resource "azurerm_subnet" "firewall" { ... }
# resource "azurerm_public_ip" "firewall" { ... }
# resource "azurerm_firewall_policy" "this" { ... }
# resource "azurerm_firewall_policy_rule_collection_group" "this" { ... }
# resource "azurerm_firewall" "this" { ... }

resource "azurerm_storage_account" "this" {
  name                     = lower(substr("${var.name}logsacct", 0, 24))
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

data "azurerm_network_watcher" "this" {
  name                = "NetworkWatcher_${data.azurerm_resource_group.this.location}"
  resource_group_name = "NetworkWatcherRG"
}

locals {
  nsgs = {
    private = azurerm_network_security_group.private.id
    public  = azurerm_network_security_group.public.id
  }
}

resource "azurerm_network_watcher_flow_log" "this" {
  for_each = local.nsgs

  name                 = "${var.name}-flowlog-${each.key}"
  network_watcher_name = data.azurerm_network_watcher.this.name
  resource_group_name  = data.azurerm_network_watcher.this.resource_group_name
  target_resource_id   = each.value
  storage_account_id   = azurerm_storage_account.this.id
  enabled              = true

  retention_policy {
    enabled = true
    days    = 30
  }

  traffic_analytics {
    enabled               = true
    workspace_region      = var.workspace_region
    workspace_id          = var.log_analytics_workspace_guid
    workspace_resource_id = var.log_analytics_workspace_id
  }

  depends_on = [
    azurerm_storage_account.this
  ]
}

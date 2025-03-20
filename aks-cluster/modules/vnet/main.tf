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
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
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
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
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

resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = data.azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

resource "azurerm_public_ip" "firewall" {
  name                = "${var.name}-firewall-pip"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones
  tags                = var.tags
}

resource "azurerm_firewall_policy" "this" {
  name                = "${var.name}-firewall-policy"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name

  dns {
    servers = var.firewall_dns_servers
  }

  threat_intelligence_mode = var.threat_intel_mode

  tags = var.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "this" {
  name               = "${var.name}-fw-policy-rcg"
  firewall_policy_id = azurerm_firewall_policy.this.id
  priority           = 100

  application_rule_collection {
    name     = "AppRules-AllowHttps"
    priority = 100
    action   = "Allow"

    rule {
      name = "AllowHTTPSOutbound"
      source_addresses = ["*"]
      protocols {
        type = "Https"
        port = 443
      }
      destination_fqdns = [
        "*.microsoft.com",
        "*.azure.com",
        "*.github.com",
        "*.docker.io",
        "*.docker.com",
        "*.azurecr.io",
        "*.amazonaws.com",
        "*.bitnami.com",
        "charts.bitnami.com",
        "*.helm.sh",
        "raw.githubusercontent.com"
     ]
    }
  }

  network_rule_collection {
    name     = "NetworkRules-AllowDNS"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "AllowDNS"
      source_addresses      = ["*"]
      destination_addresses = ["*"]
      destination_ports     = ["53"]
      protocols             = ["UDP"]
    }
  }
}

resource "azurerm_firewall" "this" {
  name                = "${var.name}-firewall"
  location            = data.azurerm_resource_group.this.location
  resource_group_name = data.azurerm_resource_group.this.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }

  firewall_policy_id = azurerm_firewall_policy.this.id

  tags = var.tags
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
  network_watcher_name = azurerm_network_watcher.this.name
  resource_group_name  = azurerm_network_watcher.this.resource_group_name
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
  azurerm_network_watcher.this,
  azurerm_storage_account.this
  ]
}

resource "azurerm_storage_account" "this" {
  name                     = lower(substr("${var.name}logsacct", 0, 24))
  resource_group_name      = data.azurerm_resource_group.this.name
  location                 = data.azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

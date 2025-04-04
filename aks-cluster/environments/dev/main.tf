# Root main.tf - Clean and fully automated version

resource "azurerm_resource_group" "rg1" {
  name     = var.rgname
  location = var.location
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name}-law"
  location            = var.location
  resource_group_name = var.rgname
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

module "ServicePrincipal" {
  source                 = "../../modules/ServicePrincipal"
  service_principal_name = var.service_principal_name

  depends_on = [
    azurerm_resource_group.rg1
  ]
}

resource "azurerm_role_assignment" "rolespn" {
  scope                = "/subscriptions/${var.SUB_ID}"
  role_definition_name = "Contributor"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [
    module.ServicePrincipal
  ]
}

module "keyvault" {
  source                      = "../../modules/keyvault"
  keyvault_name               = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.rgname
  service_principal_name      = var.service_principal_name
  service_principal_object_id = module.ServicePrincipal.service_principal_object_id
  service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id

  depends_on = [
    module.ServicePrincipal
  ]
}

resource "azurerm_key_vault_secret" "pilotgab_kv" {
  name         = module.ServicePrincipal.client_id
  value        = module.ServicePrincipal.client_secret
  key_vault_id = module.keyvault.keyvault_id

  depends_on = [
    module.keyvault
  ]
}

module "vnet" {
  source                      = "../../modules/vnet/"
  name                        = var.name
  resource_group_name         = var.rgname
  location                    = var.location
  address_space               = var.address_space
  public_subnet_cidrs         = var.public_subnet_cidrs
  private_subnet_cidrs        = var.private_subnet_cidrs
  #firewall_subnet_cidr        = var.firewall_subnet_cidr
  workspace_region            = var.location
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  log_analytics_workspace_guid   = azurerm_log_analytics_workspace.this.workspace_id

  depends_on = [
    azurerm_resource_group.rg1,
    azurerm_log_analytics_workspace.this
  ]
}

module "aks" {
  source                 = "../../modules/aks/"
  service_principal_name = var.service_principal_name
  client_id              = module.ServicePrincipal.client_id
  client_secret          = module.ServicePrincipal.client_secret
  location               = var.location
  resource_group_name    = var.rgname
  cluster_name           = var.cluster_name
  node_pool_name         = var.node_pool_name
  ssh_public_key         = var.ssh_public_key
  subnet_ids             = module.vnet.private_subnets

  depends_on = [
    module.ServicePrincipal,
    module.vnet
  ]
}

resource "local_file" "kubeconfig" {
  depends_on = [module.aks]
  filename   = "./kubeconfig"
  content    = module.aks.config
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "pilotgabstagebackend2025"
    container_name       = "tfstate"
    key                  = "stage.terraform.tfstate"
  }
}

terraform {
  backend "azurerm" {
    resource_group_name  = "ayanfeba"
    storage_account_name = "ayanayan"
    container_name       = "ayancon"
    key                  = "terraform.tfstate"
  }
}


terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.4.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  resource_providers_to_register = ["Microsoft.ContainerInstance"]
}

resource "azurerm_resource_group" "auto-corp-rg" {
  name     = "auto-corp-rg"
  location = "eastus"
}

resource "azurerm_container_group" "auto-corp-cg" {
  name                = "auto-corp-cg"
  location            = azurerm_resource_group.auto-corp-rg.location
  resource_group_name = azurerm_resource_group.auto-corp-rg.name
  ip_address_type     = "Public"
  dns_name_label      = var.container_name
  os_type             = "Linux"

  image_registry_credential {
    server   = var.registry_server
    username = var.registry_username
    password = var.registry_passwd
  }
  container {
    name   = var.container_name
    image  = var.container_image
    cpu    = "0.5"
    memory = "1.5"
    environment_variables = {
      API_URL = var.api_url
    }

    ports {
      port     = 8081
      protocol = "TCP"
    }
  }
}

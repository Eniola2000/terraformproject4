terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.27.0"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "ayanferg" {
  name     = "ayanferg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "ayanfeVnet" {
  name                = "ayanfeVnet"
  location            = azurerm_resource_group.ayanferg.location
  resource_group_name = azurerm_resource_group.ayanferg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]


  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "ayanfe-subnet" {
  name                 = "ayanfe-subnet"
  resource_group_name  = azurerm_resource_group.ayanferg.name
  virtual_network_name = azurerm_virtual_network.ayanfeVnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "ayanfe-sg" {
  name                = "ayanfe-sg"
  location            = azurerm_resource_group.ayanferg.location
  resource_group_name = azurerm_resource_group.ayanferg.name

  tags = {
    environment = "Dev"
  }
}

resource "azurerm_network_security_rule" "ayanfe-rule" {
  name                        = "ayanfe-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.ayanferg.name
  network_security_group_name = azurerm_network_security_group.ayanfe-sg.name
}

resource "azurerm_subnet_network_security_group_association" "ayanfesecgroup" {
  subnet_id                 = azurerm_subnet.ayanfe-subnet.id
  network_security_group_id = azurerm_network_security_group.ayanfe-sg.id
}
resource "azurerm_network_interface" "ayanfe-nic" {
  name                = "ayanfe-nic"
  location            = azurerm_resource_group.ayanferg.location
  resource_group_name = azurerm_resource_group.ayanferg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ayanfe-subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    environment = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "ayanfe-vm" {
  name                            = "ayanfe-vm"
  resource_group_name             = azurerm_resource_group.ayanferg.name
  location                        = azurerm_resource_group.ayanferg.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  admin_password                  = "abc59!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.ayanfe-nic.id,
  ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

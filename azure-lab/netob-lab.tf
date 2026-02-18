terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "netob-test" {
  name     = "agtx-rg-netob-test"
  location = "USGov Texas"

  lifecycle {
    ignore_changes = [
      tags["StartDate"],
    ]
  }
}

resource "azurerm_public_ip" "netob-pip" {
  name                = "agtx-pip-netob-test"
  location            = azurerm_resource_group.netob-test.location
  resource_group_name = azurerm_resource_group.netob-test.name
  allocation_method   = "Static"
  ip_version          = "IPv4"

  lifecycle {
    ignore_changes = [
      tags["StartDate"],
    ]
  }
}

resource "azurerm_virtual_network" "netob-vnet" {
  name                = "agtx-vnet-netob-test"
  address_space       = ["192.168.168.0/24"]
  location            = azurerm_resource_group.netob-test.location
  resource_group_name = azurerm_resource_group.netob-test.name

  lifecycle {
    ignore_changes = [
      tags["StartDate"],
    ]
  }
}

resource "azurerm_subnet" "netob-subnet" {
  name                 = "agtx-subnet-netob-test"
  resource_group_name  = azurerm_resource_group.netob-test.name
  virtual_network_name = azurerm_virtual_network.netob-vnet.name
  address_prefixes     = ["192.168.168.0/24"]
}

resource "azurerm_network_interface" "netob-nic" {
  name                = "agtx-nic-netob-test"
  location            = azurerm_resource_group.netob-test.location
  resource_group_name = azurerm_resource_group.netob-test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.netob-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.netob-pip.id

  }

  lifecycle {
    ignore_changes = [
      tags["StartDate"],
    ]
  }
}

resource "azurerm_linux_virtual_machine" "netob-vm" {
  name                = "agtx-vm-netob-test"
  resource_group_name = azurerm_resource_group.netob-test.name
  location            = azurerm_resource_group.netob-test.location
  size                = "Standard_D8ls_v5"
  admin_username      = "rvivian"
  network_interface_ids = [
    azurerm_network_interface.netob-nic.id,
  ]

  admin_ssh_key {
    username   = "rvivian"
    public_key = file("./.ssh/id_ecdsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  user_data = base64encode(
    templatefile(
      "cloud-config.yaml", {
        ceos-url = "https://www.arista.com/surl/CxD9A54m"
      }
    )
  )

  lifecycle {
    ignore_changes = [
      tags["StartDate"],
    ]
  }
}
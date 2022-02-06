terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  features {}
}

locals {
  rgid = format("%03d", var.rgid)
  rgfix = format("%s-%03d", var.postfix, var.rgid)
  idx = format("%03d", var.instance_count)
  postfix = format("%s", var.postfix)
}

# Reuse resource group
data "azurerm_resource_group" "ubuntu" {
    name = var.rg
}

# Reuse subnet
data "azurerm_subnet" "ubuntu" {
    name                 = var.snet
    virtual_network_name = var.vnet
    resource_group_name  = var.rg
}

# Create public IPs
resource "azurerm_public_ip" "ubuntu" {
    name                         = var.pip
    location                     = var.location
    resource_group_name          = var.rg
    allocation_method            = "Static"

    tags = {
        environment = var.tag
    }
}

# Create network interface
resource "azurerm_network_interface" "ubuntu" {
    name                      = var.nic
    location                  = var.location
    resource_group_name       = var.rg

    ip_configuration {
        name                          = var.ptip
        subnet_id                     = data.azurerm_subnet.ubuntu.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.ubuntu.id
    }

    tags = {
        environment = var.tag
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "ubuntu" {
    name                = var.nsg
    location            = var.location
    resource_group_name = var.rg

    security_rule {
        name                       = "ssh-access"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.tag
    }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  network_interface_id      = azurerm_network_interface.ubuntu.id
  network_security_group_id = azurerm_network_security_group.ubuntu.id
}

# Create virtual machine
resource "azurerm_virtual_machine" "ubuntu" {
    name                  = var.vm
    location              = var.location
    resource_group_name   = var.rg
    network_interface_ids = ["${azurerm_network_interface.ubuntu.id}"]
    vm_size               = var.size

    storage_os_disk {
        name              = var.osdisk
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = var.stype
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = var.hostname
        admin_username = "azureuser"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/azureuser/.ssh/authorized_keys"
            key_data = var.sshdata
        }
    }

    tags = {
        environment = var.tag
    }
}


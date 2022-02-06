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
  postfix = format("%s-%03d", var.postfix, var.instance_count)
}

# Reuse resource group
data "azurerm_resource_group" "centos" {
    name = var.rg
}

# Reuse subnet
data "azurerm_subnet" "centos" {
    name                 = var.snet
    virtual_network_name = var.vnet
    resource_group_name  = var.rg
}

# Create public IPs
resource "azurerm_public_ip" "centos" {
    name                         = var.pip
    location                     = var.location
    resource_group_name          = var.rg
    allocation_method            = "Static"

    tags = {
        environment = var.tag
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "centos" {
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

    security_rule {
        name                       = "mysql-access"
        priority                   = 1011
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3306"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = var.tag
    }
}

# Create network interface
resource "azurerm_network_interface" "centos" {
    name                      = var.nic
    location                  = var.location
    resource_group_name       = var.rg

    ip_configuration {
        name                          = var.ptip
        subnet_id                     = data.azurerm_subnet.centos.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.centos.id
    }

    tags = {
        environment = var.tag
    }
}

resource "azurerm_network_interface_security_group_association" "centos" {
  network_interface_id      = azurerm_network_interface.centos.id
  network_security_group_id = azurerm_network_security_group.centos.id
}

# Create virtual machine
resource "azurerm_virtual_machine" "centos" {
    name                  = var.vm
    location              = var.location
    resource_group_name   = var.rg
    network_interface_ids = ["${azurerm_network_interface.centos.id}"]
    vm_size               = var.size

    storage_os_disk {
        name              = var.osdisk
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = var.stype
    }

    storage_image_reference {
        offer     = "CentOS"
        publisher = "OpenLogic"
        sku       = "7.5"
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


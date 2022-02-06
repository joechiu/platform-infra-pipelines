
locals {
  env = upper(var.postfix)
  rgid = format("%03d", var.rgid)
  rgfix = format("%s-%03d", var.postfix, var.rgid)
  idx = format("%03d", var.instance_count)
  postfix = format("%s-%03d", var.postfix, var.instance_count)
  vm = format("%s-%s", var.postfix, var.prefix)
}

data "azurerm_resource_group" "win" {
    name = var.rg
}

data "azurerm_subnet" "win" {
  name                 = var.snet
  resource_group_name  = var.rg
  virtual_network_name = var.vnet
}

# Reuse the existing public IP
data "azurerm_public_ip" "win" {
  name                = var.pip
  resource_group_name = var.iprg
}

# Security group for subnet 
resource "azurerm_network_security_group" "win" {
  name                = var.nsg
  resource_group_name = var.rg
  location            = var.location

  security_rule {
    name                       = "rdp-access"
    priority                   = 1000
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = 3389
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "172.16.10.0/24"
    destination_address_prefix = "*"
    description                = "Allow VPN access only"
  }

  security_rule {
    name                       = "winrm-access"
    priority                   = 1010
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = 5985
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "tentacle-access"
    priority                   = 1030
    access                     = "Allow"
    direction                  = "Inbound"
    destination_port_range     = 10933
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "13.55.58.113/32"
    destination_address_prefix = "*"
    description                = "OD Integration"
  }

}

resource "azurerm_network_interface" "win" {
  name                = var.nic
  location            = var.location
  resource_group_name = data.azurerm_resource_group.win.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.win.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id  = data.azurerm_public_ip.win.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  network_interface_id      = azurerm_network_interface.win.id
  network_security_group_id = azurerm_network_security_group.win.id
}

resource "azurerm_windows_virtual_machine" "win" {
  name                = var.vm
  resource_group_name = data.azurerm_resource_group.win.name
  location            = var.location
  size                = var.size
  admin_username      = "adminuser"
  admin_password      = "Complx${local.env}P@ssw0rd!"
  provision_vm_agent =  true
  network_interface_ids = [
    azurerm_network_interface.win.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.sku
    version   = "latest"
  }

  # custom_data = base64encode("${file("./foo.ps1")}")
}

resource "azurerm_virtual_machine_extension" "win" {
  name                 = "winrm-access"
  virtual_machine_id   = azurerm_windows_virtual_machine.win.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf.rendered)}')) | Out-File -filepath foo.ps1\" && powershell -ExecutionPolicy Unrestricted -File foo.ps1"
  }
  SETTINGS
}

data "template_file" "tf" {
    template = "${file("foo.ps1")}"
}


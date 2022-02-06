resource "azurerm_managed_disk" "extra" {
  name                 = var.exdisk
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.centos.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "centos" {
  managed_disk_id    = azurerm_managed_disk.extra.id
  virtual_machine_id = azurerm_virtual_machine.centos.id
  lun                = var.disk_size
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "extra" {
  name                 = var.exdisk
  location             = var.location
  resource_group_name  = data.azurerm_resource_group.win.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk_size
}

resource "azurerm_virtual_machine_data_disk_attachment" "win" {
  managed_disk_id    = azurerm_managed_disk.extra.id
  virtual_machine_id = azurerm_windows_virtual_machine.win.id
  lun                = "10"
  caching            = "ReadWrite"
}

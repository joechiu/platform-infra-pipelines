
locals {
  tempfile = templatefile("${path.module}/temp/ssh-config.tpl", {
    pip = "${azurerm_public_ip.win.ip_address}",
    pvtip = "${azurerm_network_interface.win.private_ip_address}",
    user = "${azurerm_windows_virtual_machine.win.admin_username}",
    passwd = "Complx${local.env}P@ssw0rd!",
    hosts = var.hosts
  })
}

resource "local_file" "ssh" {
  content = local.tempfile
  filename = "${path.module}/ssh-config.yml"

  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/ssh-config.yml"
  }
}


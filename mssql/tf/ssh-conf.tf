
locals {
  tempfile = templatefile("${path.module}/temp/ssh-config.tpl", {
    ip = "${azurerm_public_ip.centos.ip_address}",
    pip = "${azurerm_network_interface.centos.private_ip_address}",
    hosts = var.hosts
    env = var.postfix
  })
}

resource "local_file" "ssh" {
  content = local.tempfile
  filename = "${path.module}/ssh-config.yml"

  provisioner "local-exec" {
    command = "ansible-playbook ${path.module}/ssh-config.yml"
  }
}


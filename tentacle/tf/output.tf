
output "public_ips" {
  description = "List of public IP addresses assigned to the instances, if applicable"
  value       = "${azurerm_public_ip.ubuntu.*.ip_address}"
}

output "private_ips" {
  description = "List of private IP addresses assigned to the instances, if applicable"
  value       = "${azurerm_network_interface.ubuntu.*.private_ip_address}"
}


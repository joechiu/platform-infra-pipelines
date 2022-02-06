output "rdp_connection_string" {
    value = "mstsc.exe /v:${data.azurerm_public_ip.win.ip_address}:3389"
}

output "rdp_connection_private" {
    value = "mstsc.exe /v:${azurerm_network_interface.win.private_ip_address}:3389"
}

output "local_win_credentials" {
    # value = "Windows user/pass = AzureAD|${azurerm_windows_virtual_machine.win.admin_username}/${random_string.winpassword.result}"
    value = "Windows user/pass = AzureAD|${azurerm_windows_virtual_machine.win.admin_username}/Complx${local.env}P@ssw0rd!"
}

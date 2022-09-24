output "Vm-ip" {
    value = azurerm_linux_virtual_machine.vm-1.public_ip_address
}

output "user-id" {
    value = azurerm_user_assigned_identity.id1.id
}

output "storage_account_name" {
    value = azurerm_storage_account.sa.name
}
output "container_name" {
    value = azurerm_storage_container.sa_container1.name
}
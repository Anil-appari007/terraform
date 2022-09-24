###############################
#  Storage Account
###############################

resource "azurerm_storage_account" "sa" {
  name                = "anilsdemo1"
  resource_group_name = azurerm_resource_group.rg.name

  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  access_tier = "Hot"
  account_replication_type = "ZRS"

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["GIVE_YOUR_IP"]
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
  }

  tags = {
    environment = "Test"
  }
}

resource "azurerm_storage_container" "sa_container1" {
  name                  = "democontainer"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}


###############################
###     User Assigned Identity
###############################
resource "azurerm_user_assigned_identity" "id1" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    name = "anilsuser1"
}

resource "azurerm_role_assignment" "role1" {
    scope = azurerm_storage_account.sa.id
    principal_id = azurerm_user_assigned_identity.id1.principal_id
    role_definition_name = "Contributor"
}
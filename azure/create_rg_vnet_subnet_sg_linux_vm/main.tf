################################
##      Resource Group
################################
resource "azurerm_resource_group" "rg" {
  location = "eastus"
  name     = "tf-anils-demo"
}

################################
##      Vnet
################################
resource "azurerm_virtual_network" "vnet" {
  address_space       = ["10.0.0.0/16"]
  name                = "anils_demo-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}

################################
##      subnet
################################
resource "azurerm_subnet" "subnet" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  depends_on = [
    azurerm_virtual_network.vnet,
  ]
}

################################
##      Public IP
################################
resource "azurerm_public_ip" "public_ip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "anils-demo-1-ip"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  depends_on = [
    azurerm_resource_group.rg,
  ]
}


################################
##      Security Group & Rules
################################
resource "azurerm_network_security_group" "sg" {
  location            = azurerm_resource_group.rg.location
  name                = "anils-demo-1-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg,
  ]
}
resource "azurerm_network_security_rule" "rule1" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "SSH"
  network_security_group_name = azurerm_network_security_group.sg.name
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.rg.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.sg,
  ]
}


################################
##      Network Interface
################################
resource "azurerm_network_interface" "ni-1" {
  location            = azurerm_resource_group.rg.location
  name                = "anils-demo-114"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip.id
    subnet_id = azurerm_subnet.subnet.id
  }

  depends_on = [
    azurerm_public_ip.public_ip,
    azurerm_subnet.subnet,
    azurerm_network_security_group.sg,
  ]
}


################################
##      Attach Security Group & Network Interface
################################

resource "azurerm_network_interface_security_group_association" "attach-sg-ni" {
  network_interface_id      = azurerm_network_interface.ni-1.id
  network_security_group_id = azurerm_network_security_group.sg.id
}


################################
##      Linux VM
################################

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

resource "local_file" "ssh_private_key" {
  content           = tls_private_key.ssh.private_key_pem
  filename          = "./tls/private.pem"
  file_permission   = "0600"
}

resource "azurerm_linux_virtual_machine" "vm-1" {

  admin_username                  = "anil"
  disable_password_authentication = true
  location                        = azurerm_resource_group.rg.location
  name                            = "anils-demo-1"

  admin_ssh_key {
    username   = "anil"
    # public_key = file("./ssh_keys/id_rsa.pub")    ## use this if you existing keys
    public_key = tls_private_key.ssh.public_key_openssh
  }
  network_interface_ids = [
    azurerm_network_interface.ni-1.id,
    ]
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_B1s"
  boot_diagnostics {
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "canonical"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.ni-1,
  ]
}




# Azure Web Hosting Solution - Main Configuration
# This configuration deploys a multi-environment web hosting solution
# with load balancing and high availability

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate${random_string.suffix.result}"
    container_name       = "terraform-state"
    key                  = "web-hosting.tfstate"
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}

# Random string for unique resource naming
resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-web-hosting-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-web-hosting-${var.environment}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Subnet for web servers
resource "azurerm_subnet" "web_servers" {
  name                 = "subnet-web-servers"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.web_subnet_address_prefix]
}

# Subnet for load balancer
resource "azurerm_subnet" "load_balancer" {
  name                 = "subnet-load-balancer"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.lb_subnet_address_prefix]
}

# Network Security Group for web servers
resource "azurerm_network_security_group" "web_servers" {
  name                = "nsg-web-servers-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.management_subnet_cidr
    destination_address_prefix = "*"
  }

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Associate NSG with web servers subnet
resource "azurerm_subnet_network_security_group_association" "web_servers" {
  subnet_id                 = azurerm_subnet.web_servers.id
  network_security_group_id = azurerm_network_security_group.web_servers.id
}

# Public IP for load balancer
resource "azurerm_public_ip" "load_balancer" {
  name                = "pip-load-balancer-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Load Balancer
resource "azurerm_lb" "main" {
  name                = "lb-web-hosting-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = var.environment == "prod" ? "Standard" : "Basic"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.load_balancer.id
  }

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Backend Address Pool
resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "BackEndAddressPool"
}

# Load Balancer Health Probe
resource "azurerm_lb_probe" "main" {
  loadbalancer_id = azurerm_lb.main.id
  name            = "http-health-probe"
  port            = 80
  protocol        = "Http"
  request_path    = "/"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "main" {
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.main.id]
  probe_id                       = azurerm_lb_probe.main.id
}

# Network interfaces for web servers
resource "azurerm_network_interface" "web_servers" {
  count               = var.vm_count
  name                = "nic-web-server-${count.index + 1}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web_servers.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Associate network interfaces with load balancer backend pool
resource "azurerm_network_interface_backend_address_pool_association" "web_servers" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.web_servers[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

# Virtual Machines for web servers
resource "azurerm_linux_virtual_machine" "web_servers" {
  count               = var.vm_count
  name                = "vm-web-server-${count.index + 1}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = var.vm_size
  admin_username      = var.admin_username
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.web_servers[count.index].id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Custom Script Extension for web server setup
resource "azurerm_virtual_machine_extension" "web_server_setup" {
  count                = var.vm_count
  name                 = "web-server-setup"
  virtual_machine_id   = azurerm_linux_virtual_machine.web_servers[count.index].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "fileUris": ["${azurerm_storage_blob.web_server_setup.url}"],
        "commandToExecute": "bash web-server-setup.sh"
    }
SETTINGS

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Storage account for scripts
resource "azurerm_storage_account" "scripts" {
  name                     = "stscripts${var.environment}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Storage container for scripts
resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.scripts.name
  container_access_type = "blob"
}

# Upload web server setup script
resource "azurerm_storage_blob" "web_server_setup" {
  name                   = "web-server-setup.sh"
  storage_account_name   = azurerm_storage_account.scripts.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "${path.module}/../scripts/web-server-setup.sh"
}

# Key Vault for storing secrets
resource "azurerm_key_vault" "main" {
  name                = "kv-web-hosting-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
      "Recover",
      "Backup",
      "Restore",
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]
  }

  tags = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

# Store admin password in Key Vault
resource "azurerm_key_vault_secret" "admin_password" {
  name         = "admin-password"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.main.id
}

# Azure Web Hosting Solution - Outputs
# This file contains all output definitions for the web hosting solution

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "web_subnet_id" {
  description = "ID of the web servers subnet"
  value       = azurerm_subnet.web_servers.id
}

output "load_balancer_subnet_id" {
  description = "ID of the load balancer subnet"
  value       = azurerm_subnet.load_balancer.id
}

output "load_balancer_public_ip" {
  description = "Public IP address of the load balancer"
  value       = azurerm_public_ip.load_balancer.ip_address
}

output "load_balancer_fqdn" {
  description = "FQDN of the load balancer"
  value       = azurerm_public_ip.load_balancer.fqdn
}

output "load_balancer_name" {
  description = "Name of the load balancer"
  value       = azurerm_lb.main.name
}

output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = azurerm_lb.main.id
}

output "web_server_vm_names" {
  description = "Names of the web server VMs"
  value       = azurerm_linux_virtual_machine.web_servers[*].name
}

output "web_server_vm_ids" {
  description = "IDs of the web server VMs"
  value       = azurerm_linux_virtual_machine.web_servers[*].id
}

output "web_server_private_ips" {
  description = "Private IP addresses of the web server VMs"
  value       = azurerm_network_interface.web_servers[*].private_ip_address
}

output "network_security_group_name" {
  description = "Name of the network security group"
  value       = azurerm_network_security_group.web_servers.name
}

output "network_security_group_id" {
  description = "ID of the network security group"
  value       = azurerm_network_security_group.web_servers.id
}

output "storage_account_name" {
  description = "Name of the storage account for scripts"
  value       = azurerm_storage_account.scripts.name
}

output "storage_account_primary_endpoint" {
  description = "Primary endpoint of the storage account"
  value       = azurerm_storage_account.scripts.primary_blob_endpoint
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.main.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "backend_address_pool_id" {
  description = "ID of the load balancer backend address pool"
  value       = azurerm_lb_backend_address_pool.main.id
}

output "health_probe_id" {
  description = "ID of the load balancer health probe"
  value       = azurerm_lb_probe.main.id
}

output "load_balancer_rule_id" {
  description = "ID of the load balancer rule"
  value       = azurerm_lb_rule.main.id
}

output "application_url" {
  description = "URL to access the web application"
  value       = "http://${azurerm_public_ip.load_balancer.ip_address}"
}

output "application_https_url" {
  description = "HTTPS URL to access the web application"
  value       = "https://${azurerm_public_ip.load_balancer.ip_address}"
}

output "ssh_connection_commands" {
  description = "SSH commands to connect to web servers (via bastion or jump host)"
  value = {
    for i, vm in azurerm_linux_virtual_machine.web_servers : 
    vm.name => "ssh ${var.admin_username}@${azurerm_network_interface.web_servers[i].private_ip_address}"
  }
}

output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "vm_count" {
  description = "Number of VMs deployed"
  value       = var.vm_count
}

output "vm_size" {
  description = "Size of the VMs"
  value       = var.vm_size
}

output "web_server_type" {
  description = "Type of web server installed"
  value       = var.web_server_type
}

output "terraform_backend_info" {
  description = "Information about Terraform backend configuration"
  value = {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate${random_string.suffix.result}"
    container_name       = "terraform-state"
    key                  = "web-hosting.tfstate"
  }
}

output "deployment_timestamp" {
  description = "Timestamp of the deployment"
  value       = timestamp()
}

output "resource_tags" {
  description = "Tags applied to resources"
  value = {
    Environment = var.environment
    Project     = "WebHosting"
    ManagedBy   = "Terraform"
  }
}

output "monitoring_endpoints" {
  description = "Endpoints for monitoring and health checks"
  value = {
    health_check_url     = "http://${azurerm_public_ip.load_balancer.ip_address}${var.health_check_path}"
    load_balancer_status = "http://${azurerm_public_ip.load_balancer.ip_address}/health"
  }
}

output "network_configuration" {
  description = "Network configuration details"
  value = {
    vnet_address_space        = var.vnet_address_space
    web_subnet_address_prefix = var.web_subnet_address_prefix
    lb_subnet_address_prefix  = var.lb_subnet_address_prefix
  }
}

output "security_configuration" {
  description = "Security configuration details"
  value = {
    nsg_name                 = azurerm_network_security_group.web_servers.name
    key_vault_name           = azurerm_key_vault.main.name
    allowed_ip_ranges        = var.allowed_ip_ranges
    enable_https_redirect    = var.enable_https_redirect
  }
}

output "storage_configuration" {
  description = "Storage configuration details"
  value = {
    storage_account_name     = azurerm_storage_account.scripts.name
    storage_account_tier     = var.storage_account_tier
    storage_replication_type = var.storage_replication_type
  }
}

output "backup_configuration" {
  description = "Backup configuration details"
  value = {
    backup_enabled         = var.enable_backup
    backup_retention_days  = var.backup_retention_days
  }
}

output "auto_scaling_configuration" {
  description = "Auto-scaling configuration details"
  value = {
    auto_scaling_enabled = var.enable_auto_scaling
    min_capacity         = var.min_capacity
    max_capacity         = var.max_capacity
  }
}

output "load_balancer_configuration" {
  description = "Load balancer configuration details"
  value = {
    lb_name                        = azurerm_lb.main.name
    lb_sku                         = azurerm_lb.main.sku
    health_check_path              = var.health_check_path
    health_check_protocol          = var.health_check_protocol
    session_affinity               = var.session_affinity
    connection_draining_timeout    = var.connection_draining_timeout
  }
}

output "dns_configuration" {
  description = "DNS configuration details"
  value = {
    domain_name              = var.domain_name
    public_ip_fqdn           = azurerm_public_ip.load_balancer.fqdn
    public_ip_address        = azurerm_public_ip.load_balancer.ip_address
  }
}

output "ssl_configuration" {
  description = "SSL configuration details"
  value = {
    ssl_certificate_path     = var.ssl_certificate_path
    ssl_key_path             = var.ssl_key_path
    https_redirect_enabled   = var.enable_https_redirect
  }
}

output "deployment_summary" {
  description = "Summary of the deployment"
  value = {
    environment              = var.environment
    location                 = var.location
    vm_count                 = var.vm_count
    vm_size                  = var.vm_size
    web_server_type          = var.web_server_type
    load_balancer_ip         = azurerm_public_ip.load_balancer.ip_address
    application_url          = "http://${azurerm_public_ip.load_balancer.ip_address}"
    deployment_timestamp     = timestamp()
  }
}

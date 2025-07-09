# Development Environment Configuration
# This file contains variables specific to the development environment

environment = "dev"
location    = "East US"

# VM Configuration
vm_count    = 2
vm_size     = "Standard_B2s"
disk_size_gb = 30
disk_storage_account_type = "StandardSSD_LRS"

# Network Configuration
vnet_address_space          = "10.0.0.0/16"
web_subnet_address_prefix   = "10.0.1.0/24"
lb_subnet_address_prefix    = "10.0.2.0/24"
management_subnet_cidr      = "10.0.3.0/24"

# Security Configuration
allowed_ip_ranges = ["0.0.0.0/0"]  # Allow all IPs for development
enable_https_redirect = false

# Web Server Configuration
web_server_type = "nginx"
health_check_path = "/health"
health_check_protocol = "Http"

# Scaling Configuration
enable_auto_scaling = false
min_capacity = 2
max_capacity = 4

# Storage Configuration
storage_account_tier = "Standard"
storage_replication_type = "LRS"

# Key Vault Configuration
key_vault_sku = "standard"
enable_key_vault_purge_protection = false
key_vault_soft_delete_retention_days = 7

# Backup Configuration
enable_backup = false
backup_retention_days = 7

# Monitoring Configuration
enable_monitoring = true
enable_network_watcher = true

# Load Balancer Configuration
session_affinity = false
connection_draining_timeout = 60

# DDoS Protection
enable_ddos_protection = false

# SSL Configuration
ssl_certificate_path = ""
ssl_key_path = ""
domain_name = ""

# Availability Zones
availability_zones = ["1"]

# Networking Features
enable_accelerated_networking = false

# Custom Tags
tags = {
  Environment = "dev"
  Project     = "WebHosting"
  Owner       = "DevTeam"
  CostCenter  = "Engineering"
  Purpose     = "Development"
}

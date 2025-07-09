# Production Environment Configuration
# This file contains variables specific to the production environment

environment = "prod"
location    = "West US 2"

# VM Configuration
vm_count    = 3
vm_size     = "Standard_D2s_v3"
disk_size_gb = 100
disk_storage_account_type = "Premium_LRS"

# Network Configuration
vnet_address_space          = "10.2.0.0/16"
web_subnet_address_prefix   = "10.2.1.0/24"
lb_subnet_address_prefix    = "10.2.2.0/24"
management_subnet_cidr      = "10.2.3.0/24"

# Security Configuration
allowed_ip_ranges = ["10.0.0.0/8", "172.16.0.0/12"]  # Restricted to private networks
enable_https_redirect = true

# Web Server Configuration
web_server_type = "nginx"
health_check_path = "/health"
health_check_protocol = "Https"

# Scaling Configuration
enable_auto_scaling = true
min_capacity = 3
max_capacity = 10

# Storage Configuration
storage_account_tier = "Premium"
storage_replication_type = "GRS"

# Key Vault Configuration
key_vault_sku = "premium"
enable_key_vault_purge_protection = true
key_vault_soft_delete_retention_days = 90

# Backup Configuration
enable_backup = true
backup_retention_days = 90

# Monitoring Configuration
enable_monitoring = true
enable_network_watcher = true

# Load Balancer Configuration
session_affinity = true
connection_draining_timeout = 300

# DDoS Protection
enable_ddos_protection = true

# SSL Configuration
ssl_certificate_path = "/path/to/ssl/certificate.crt"
ssl_key_path = "/path/to/ssl/private.key"
domain_name = "www.example.com"

# Availability Zones
availability_zones = ["1", "2", "3"]

# Networking Features
enable_accelerated_networking = true

# Custom Tags
tags = {
  Environment = "prod"
  Project     = "WebHosting"
  Owner       = "ProdTeam"
  CostCenter  = "Operations"
  Purpose     = "Production"
  Criticality = "High"
  Compliance  = "Required"
}

# Azure Web Hosting Solution - Variables
# This file contains all variable definitions for the web hosting solution

variable "environment" {
  description = "Environment name (dev, uat, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment must be one of: dev, uat, prod."
  }
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "vm_count" {
  description = "Number of web server VMs to create"
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 10
    error_message = "VM count must be between 1 and 10."
  }
}

variable "vm_size" {
  description = "Size of the VMs"
  type        = string
  default     = "Standard_B2s"

  validation {
    condition = can(regex("^Standard_", var.vm_size))
    error_message = "VM size must be a valid Azure VM size starting with 'Standard_'."
  }
}

variable "admin_username" {
  description = "Administrator username for VMs"
  type        = string
  default     = "azureuser"

  validation {
    condition     = length(var.admin_username) >= 3 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 3 and 20 characters."
  }
}

variable "admin_password" {
  description = "Administrator password for VMs"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 8
    error_message = "Admin password must be at least 8 characters long."
  }
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition = can(cidrhost(var.vnet_address_space, 0))
    error_message = "VNet address space must be a valid CIDR notation."
  }
}

variable "web_subnet_address_prefix" {
  description = "Address prefix for the web servers subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition = can(cidrhost(var.web_subnet_address_prefix, 0))
    error_message = "Web subnet address prefix must be a valid CIDR notation."
  }
}

variable "lb_subnet_address_prefix" {
  description = "Address prefix for the load balancer subnet"
  type        = string
  default     = "10.0.2.0/24"

  validation {
    condition = can(cidrhost(var.lb_subnet_address_prefix, 0))
    error_message = "Load balancer subnet address prefix must be a valid CIDR notation."
  }
}

variable "management_subnet_cidr" {
  description = "CIDR block for management subnet (for SSH access)"
  type        = string
  default     = "10.0.3.0/24"

  validation {
    condition = can(cidrhost(var.management_subnet_cidr, 0))
    error_message = "Management subnet CIDR must be a valid CIDR notation."
  }
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the VM scale set"
  type        = bool
  default     = false
}

variable "min_capacity" {
  description = "Minimum number of VMs in the scale set"
  type        = number
  default     = 2

  validation {
    condition     = var.min_capacity >= 1
    error_message = "Minimum capacity must be at least 1."
  }
}

variable "max_capacity" {
  description = "Maximum number of VMs in the scale set"
  type        = number
  default     = 10

  validation {
    condition     = var.max_capacity >= var.min_capacity
    error_message = "Maximum capacity must be greater than or equal to minimum capacity."
  }
}

variable "web_server_type" {
  description = "Type of web server to install (nginx, apache, iis)"
  type        = string
  default     = "nginx"

  validation {
    condition     = contains(["nginx", "apache", "iis"], var.web_server_type)
    error_message = "Web server type must be one of: nginx, apache, iis."
  }
}

variable "ssl_certificate_path" {
  description = "Path to SSL certificate file"
  type        = string
  default     = ""
}

variable "ssl_key_path" {
  description = "Path to SSL private key file"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Domain name for the web application"
  type        = string
  default     = ""
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor for the resources"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for monitoring"
  type        = string
  default     = ""
}

variable "backup_retention_days" {
  description = "Number of days to retain VM backups"
  type        = number
  default     = 30

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}

variable "enable_backup" {
  description = "Enable Azure Backup for VMs"
  type        = bool
  default     = true
}

variable "custom_data" {
  description = "Custom data script to run on VM startup"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access the web servers"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_https_redirect" {
  description = "Enable HTTP to HTTPS redirect"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "Path for load balancer health check"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Protocol for load balancer health check"
  type        = string
  default     = "Http"

  validation {
    condition     = contains(["Http", "Https", "Tcp"], var.health_check_protocol)
    error_message = "Health check protocol must be one of: Http, Https, Tcp."
  }
}

variable "session_affinity" {
  description = "Enable session affinity (sticky sessions)"
  type        = bool
  default     = false
}

variable "connection_draining_timeout" {
  description = "Connection draining timeout in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.connection_draining_timeout >= 0 && var.connection_draining_timeout <= 3600
    error_message = "Connection draining timeout must be between 0 and 3600 seconds."
  }
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection for the virtual network"
  type        = bool
  default     = false
}

variable "ddos_protection_plan_id" {
  description = "DDoS protection plan ID (required if enable_ddos_protection is true)"
  type        = string
  default     = ""
}

variable "enable_network_watcher" {
  description = "Enable Network Watcher for monitoring"
  type        = bool
  default     = true
}

variable "storage_account_tier" {
  description = "Storage account tier for scripts and diagnostics"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Storage account tier must be either Standard or Premium."
  }
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS"], var.storage_replication_type)
    error_message = "Storage replication type must be one of: LRS, GRS, RAGRS, ZRS."
  }
}

variable "key_vault_sku" {
  description = "Key Vault SKU"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "Key Vault SKU must be either standard or premium."
  }
}

variable "enable_key_vault_purge_protection" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  description = "Soft delete retention days for Key Vault"
  type        = number
  default     = 90

  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "Key Vault soft delete retention days must be between 7 and 90."
  }
}

variable "availability_zones" {
  description = "List of availability zones for VM deployment"
  type        = list(string)
  default     = ["1", "2"]
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking on network interfaces"
  type        = bool
  default     = false
}

variable "disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.disk_size_gb >= 30 && var.disk_size_gb <= 1024
    error_message = "Disk size must be between 30 and 1024 GB."
  }
}

variable "disk_caching" {
  description = "OS disk caching type"
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["ReadWrite", "ReadOnly", "None"], var.disk_caching)
    error_message = "Disk caching must be one of: ReadWrite, ReadOnly, None."
  }
}

variable "disk_storage_account_type" {
  description = "OS disk storage account type"
  type        = string
  default     = "Premium_LRS"

  validation {
    condition     = contains(["Premium_LRS", "StandardSSD_LRS", "Standard_LRS"], var.disk_storage_account_type)
    error_message = "Disk storage account type must be one of: Premium_LRS, StandardSSD_LRS, Standard_LRS."
  }
}

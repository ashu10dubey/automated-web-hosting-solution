#!/bin/bash

# Azure Backend Setup Script for Terraform
# This script creates the necessary Azure resources for Terraform state management

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RESOURCE_GROUP_NAME="rg-terraform-state"
STORAGE_ACCOUNT_NAME="stterraformstate$(date +%s)"
CONTAINER_NAME="terraform-state"
LOCATION="East US"
SUBSCRIPTION_ID=""

# Functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Azure CLI is installed
check_azure_cli() {
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    print_success "Azure CLI is installed"
}

# Check if user is logged in
check_azure_login() {
    if ! az account show &> /dev/null; then
        print_error "Please log in to Azure CLI first using 'az login'"
        exit 1
    fi
    print_success "Azure CLI is authenticated"
}

# Get subscription ID
get_subscription_id() {
    SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)
    print_info "Using subscription: $SUBSCRIPTION_ID"
}

# Create resource group
create_resource_group() {
    print_info "Creating resource group: $RESOURCE_GROUP_NAME"
    
    if az group show --name "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_warning "Resource group $RESOURCE_GROUP_NAME already exists"
    else
        az group create --name "$RESOURCE_GROUP_NAME" --location "$LOCATION"
        print_success "Resource group created successfully"
    fi
}

# Create storage account
create_storage_account() {
    print_info "Creating storage account: $STORAGE_ACCOUNT_NAME"
    
    if az storage account show --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP_NAME" &> /dev/null; then
        print_warning "Storage account $STORAGE_ACCOUNT_NAME already exists"
    else
        az storage account create \
            --name "$STORAGE_ACCOUNT_NAME" \
            --resource-group "$RESOURCE_GROUP_NAME" \
            --location "$LOCATION" \
            --sku "Standard_LRS" \
            --kind "StorageV2" \
            --https-only true \
            --min-tls-version "TLS1_2"
        print_success "Storage account created successfully"
    fi
}

# Create container
create_container() {
    print_info "Creating container: $CONTAINER_NAME"
    
    # Get storage account key
    STORAGE_KEY=$(az storage account keys list --resource-group "$RESOURCE_GROUP_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --query "[0].value" -o tsv)
    
    if az storage container show --name "$CONTAINER_NAME" --account-name "$STORAGE_ACCOUNT_NAME" --account-key "$STORAGE_KEY" &> /dev/null; then
        print_warning "Container $CONTAINER_NAME already exists"
    else
        az storage container create \
            --name "$CONTAINER_NAME" \
            --account-name "$STORAGE_ACCOUNT_NAME" \
            --account-key "$STORAGE_KEY"
        print_success "Container created successfully"
    fi
}

# Create service principal
create_service_principal() {
    print_info "Creating service principal for Terraform"
    
    SP_NAME="terraform-sp-$(date +%s)"
    
    # Create service principal
    SP_OUTPUT=$(az ad sp create-for-rbac \
        --name "$SP_NAME" \
        --role="Contributor" \
        --scopes="/subscriptions/$SUBSCRIPTION_ID" \
        --sdk-auth)
    
    # Extract values
    CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.clientId')
    CLIENT_SECRET=$(echo "$SP_OUTPUT" | jq -r '.clientSecret')
    TENANT_ID=$(echo "$SP_OUTPUT" | jq -r '.tenantId')
    
    print_success "Service principal created successfully"
    print_info "Client ID: $CLIENT_ID"
    print_info "Tenant ID: $TENANT_ID"
    print_warning "Client Secret: $CLIENT_SECRET (save this securely)"
}

# Generate backend configuration
generate_backend_config() {
    print_info "Generating backend configuration"
    
    cat > backend.tf << EOF
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP_NAME"
    storage_account_name = "$STORAGE_ACCOUNT_NAME"
    container_name       = "$CONTAINER_NAME"
    key                  = "terraform.tfstate"
  }
}
EOF
    
    print_success "Backend configuration saved to backend.tf"
}

# Generate environment variables
generate_env_vars() {
    print_info "Generating environment variables file"
    
    cat > .env << EOF
# Azure Authentication
export ARM_CLIENT_ID="$CLIENT_ID"
export ARM_CLIENT_SECRET="$CLIENT_SECRET"
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export ARM_TENANT_ID="$TENANT_ID"

# Terraform Backend
export TF_BACKEND_RESOURCE_GROUP="$RESOURCE_GROUP_NAME"
export TF_BACKEND_STORAGE_ACCOUNT="$STORAGE_ACCOUNT_NAME"
export TF_BACKEND_CONTAINER="$CONTAINER_NAME"
EOF
    
    print_success "Environment variables saved to .env"
    print_warning "Make sure to source this file: source .env"
}

# Main execution
main() {
    print_info "Starting Azure backend setup for Terraform"
    
    check_azure_cli
    check_azure_login
    get_subscription_id
    create_resource_group
    create_storage_account
    create_container
    create_service_principal
    generate_backend_config
    generate_env_vars
    
    print_success "Azure backend setup completed successfully!"
    print_info "Next steps:"
    print_info "1. Source the environment variables: source .env"
    print_info "2. Initialize Terraform: terraform init"
    print_info "3. Plan your deployment: terraform plan"
    print_info "4. Apply your configuration: terraform apply"
}

# Run main function
main "$@"
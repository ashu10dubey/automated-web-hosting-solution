#!/bin/bash
# deploy.sh

ENVIRONMENT=$1
SUBSCRIPTION_ID=$2
AUTO_APPROVE=$3

if [ -z "$ENVIRONMENT" ] || [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Usage: ./deploy.sh <environment> <subscription-id> [auto-approve]"
    exit 1
fi

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(dev|uat|prod)$ ]]; then
    echo "Error: Environment must be dev, uat, or prod"
    exit 1
fi

# Set Azure context
az account set --subscription "$SUBSCRIPTION_ID"

# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="../environments/$ENVIRONMENT.tfvars" -out="$ENVIRONMENT.tfplan"

# Apply deployment
if [ "$AUTO_APPROVE" = "auto-approve" ]; then
    terraform apply -auto-approve "$ENVIRONMENT.tfplan"
else
    terraform apply "$ENVIRONMENT.tfplan"
fi

echo "Deployment to $ENVIRONMENT environment completed successfully!"
# This script deploys the web server using Terraform based on the specified environment and subscription ID.
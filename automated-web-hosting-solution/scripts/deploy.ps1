# deploy.ps1
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "uat", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove
)

# Set Azure context
az account set --subscription $SubscriptionId

# Navigate to terraform directory
Set-Location -Path "terraform"

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="../environments/$Environment.tfvars" -out="$Environment.tfplan"

# Apply deployment
if ($AutoApprove) {
    terraform apply -auto-approve "$Environment.tfplan"
} else {
    terraform apply "$Environment.tfplan"
}

Write-Host "Deployment to $Environment environment completed successfully!"

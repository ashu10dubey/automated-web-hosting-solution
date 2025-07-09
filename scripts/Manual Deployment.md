# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan deployment for specific environment
terraform plan -var-file="../environments/dev.tfvars"

# Apply configuration
terraform apply -var-file="../environments/dev.tfvars"

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.lms.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.lms.name
}

output "storage_account_connection_string" {
  description = "Connection string for storage account"
  value       = azurerm_storage_account.lms.primary_connection_string
  sensitive   = true
}

output "storage_blob_endpoint" {
  description = "Blob endpoint URL"
  value       = azurerm_storage_account.lms.primary_blob_endpoint
}

output "storage_sas_url" {
  description = "Storage account SAS URL for frontend"
  value       = "${azurerm_storage_account.lms.primary_blob_endpoint}?${data.azurerm_storage_account_sas.lms.sas}"
  sensitive   = true
}

output "container_registry_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.lms.name
}

output "container_registry_login_server" {
  description = "Login server for ACR"
  value       = azurerm_container_registry.lms.login_server
}

output "container_registry_admin_username" {
  description = "Admin username for ACR"
  value       = azurerm_container_registry.lms.admin_username
  sensitive   = true
}

output "container_registry_admin_password" {
  description = "Admin password for ACR"
  value       = azurerm_container_registry.lms.admin_password
  sensitive   = true
}

output "container_instance_fqdn" {
  description = "Fully qualified domain name of the container instance"
  value       = azurerm_container_group.lms.fqdn
}

output "application_url" {
  description = "Public URL of the application"
  value       = "http://${azurerm_container_group.lms.fqdn}"
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.lms.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.lms.connection_string
  sensitive   = true
}

# Output for GitHub Secrets setup
output "github_secrets_instructions" {
  description = "Instructions for setting up GitHub secrets"
  value = <<-EOT
  
  ====================================
  GitHub Secrets Configuration
  ====================================
  
  Add these secrets to your GitHub repository:
  (Settings -> Secrets and variables -> Actions -> New repository secret)
  
  1. AZURE_CREDENTIALS:
     Run this command and copy the entire JSON output:
     
     az ad sp create-for-rbac --name "lms-github-actions" \
       --role contributor \
       --scopes /subscriptions/{subscription-id}/resourceGroups/${azurerm_resource_group.lms.name} \
       --sdk-auth
  
  2. ACR_USERNAME: ${azurerm_container_registry.lms.admin_username}
  
  3. ACR_PASSWORD: (Use command below to retrieve)
     terraform output -raw container_registry_admin_password
  
  ====================================
  Update Your index.html
  ====================================
  
  Replace the blobSasUrl in index.html with:
  terraform output -raw storage_sas_url
  
  ====================================
  
  EOT
}
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Optional: Configure backend for state management
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstatestore"
  #   container_name       = "tfstate"
  #   key                  = "lms.terraform.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Random string for unique naming
resource "random_string" "unique" {
  length  = 6
  special = false
  upper   = false
}

# Resource Group
resource "azurerm_resource_group" "lms" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Storage Account for books
resource "azurerm_storage_account" "lms" {
  name                     = "${var.storage_account_prefix}${random_string.unique.result}"
  resource_group_name      = azurerm_resource_group.lms.name
  location                 = azurerm_resource_group.lms.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  blob_properties {
    cors_rule {
      allowed_origins    = ["*"]
      allowed_methods    = ["GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS"]
      allowed_headers    = ["*"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  tags = var.tags
}

# Storage Container for books
resource "azurerm_storage_container" "books" {
  name                  = "books"
  storage_account_name  = azurerm_storage_account.lms.name
  container_access_type = "blob"
}

# Generate SAS token for storage account
data "azurerm_storage_account_sas" "lms" {
  connection_string = azurerm_storage_account.lms.primary_connection_string
  https_only        = true
  signed_version    = "2024-11-04"

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = true
    table = true
    file  = true
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "8760h") # 1 year

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    tag     = true
    filter  = true
  }
}

# Container Registry
resource "azurerm_container_registry" "lms" {
  name                = "${var.acr_name}${random_string.unique.result}"
  resource_group_name = azurerm_resource_group.lms.name
  location            = azurerm_resource_group.lms.location
  sku                 = "Basic"
  admin_enabled       = true

  tags = var.tags
}

# Container Instance
resource "azurerm_container_group" "lms" {
  name                = var.container_instance_name
  location            = azurerm_resource_group.lms.location
  resource_group_name = azurerm_resource_group.lms.name
  os_type             = "Linux"
  dns_name_label      = "${var.dns_name_label}-${random_string.unique.result}"

  image_registry_credential {
    server   = azurerm_container_registry.lms.login_server
    username = azurerm_container_registry.lms.admin_username
    password = azurerm_container_registry.lms.admin_password
  }

  container {
    name   = "lms-app"
    image  = "${azurerm_container_registry.lms.login_server}/lms:latest"
    cpu    = var.container_cpu
    memory = var.container_memory

    ports {
      port     = 80
      protocol = "TCP"
    }

    environment_variables = {
      STORAGE_ACCOUNT_NAME = azurerm_storage_account.lms.name
      CONTAINER_NAME       = azurerm_storage_container.books.name
    }
  }

  tags = var.tags

  # This will be updated by CI/CD pipeline
  lifecycle {
    ignore_changes = [
      container[0].image
    ]
  }
}

# Log Analytics Workspace (optional but recommended for monitoring)
resource "azurerm_log_analytics_workspace" "lms" {
  name                = "${var.project_name}-logs-${random_string.unique.result}"
  location            = azurerm_resource_group.lms.location
  resource_group_name = azurerm_resource_group.lms.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

# Application Insights for monitoring
resource "azurerm_application_insights" "lms" {
  name                = "${var.project_name}-insights-${random_string.unique.result}"
  location            = azurerm_resource_group.lms.location
  resource_group_name = azurerm_resource_group.lms.name
  workspace_id        = azurerm_log_analytics_workspace.lms.id
  application_type    = "web"

  tags = var.tags
}

# Azure OpenAI (optional - requires application/approval)
# Uncomment if you have access to Azure OpenAI
# resource "azurerm_cognitive_account" "openai" {
#   name                = "${var.project_name}-openai-${random_string.unique.result}"
#   location            = "eastus"  # Azure OpenAI is available in limited regions
#   resource_group_name = azurerm_resource_group.lms.name
#   kind                = "OpenAI"
#   sku_name            = "S0"
#
#   tags = var.tags
# }
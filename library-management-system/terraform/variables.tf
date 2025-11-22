variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "LIB1"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "lms"
}

variable "storage_account_prefix" {
  description = "Storage account name prefix (must be lowercase, no special chars)"
  type        = string
  default     = "library"
}

variable "acr_name" {
  description = "Azure Container Registry name prefix"
  type        = string
  default     = "lmsacr"
}

variable "container_instance_name" {
  description = "Name of the container instance"
  type        = string
  default     = "lms-app"
}

variable "dns_name_label" {
  description = "DNS name label for container instance"
  type        = string
  default     = "lms-app-unique"
}

variable "container_cpu" {
  description = "CPU allocation for container"
  type        = number
  default     = 1
}

variable "container_memory" {
  description = "Memory allocation for container in GB"
  type        = number
  default     = 1.5
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "Library Management System"
    ManagedBy   = "Terraform"
  }
}
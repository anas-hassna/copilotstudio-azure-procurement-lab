variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
  default     = "rg-procurement-rag"
}

variable "location" {
  description = "Azure region for resources."
  type        = string
  default     = "francecentral"
}

variable "environment_name" {
  description = "Environment name for resource naming."
  type        = string
  default     = "poc"
}

variable "tags" {
  description = "Tags for all resources."
  type        = map(string)
  default     = {}
}

# AI Search
variable "search_sku" {
  description = "AI Search SKU (free, basic, standard)."
  type        = string
  default     = "basic"
}

# Embedding model
variable "embedding_model" {
  description = "Embedding model deployment name."
  type        = string
  default     = "text-embedding-ada-002"
}

# SharePoint
variable "sharepoint_site_name" {
  description = "SharePoint site display name."
  type        = string
  default     = "Marches GHT Contoso"
}

variable "sharepoint_site_alias" {
  description = "SharePoint site URL alias (no spaces)."
  type        = string
  default     = "marches-ght-contoso"
}

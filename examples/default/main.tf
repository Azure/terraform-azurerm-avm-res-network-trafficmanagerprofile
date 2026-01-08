terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {
}


## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

# Generate a unique Traffic Manager profile name
resource "random_string" "tm_suffix" {
  length  = 8
  special = false
  upper   = false
}

# This is the module call for Traffic Manager Profile
module "test" {
  source = "../../"

  # source             = "Azure/avm-res-network-trafficmanagerprofile/azurerm"
  # ...
  location            = "global" # Traffic Manager profiles are global
  name                = "tm-${random_string.tm_suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  enable_telemetry    = var.enable_telemetry # see variables.tf

  # Traffic Manager specific configuration
  traffic_routing_method = "Performance"

  dns_config = {
    relative_name = "tm-${random_string.tm_suffix.result}"
    ttl           = 60
  }

  monitor_config = {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }

  profile_status = "Enabled"
}

# Example: Create a public IP for the Azure Endpoint
resource "azurerm_public_ip" "example" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.this.location
  name                = "pip-${random_string.tm_suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
}

# Example: Azure Endpoint using the submodule
module "azure_endpoint" {
  source = "../../modules/azureendpoints"

  traffic_manager_profile_id = module.test.resource_id
  name                       = "azure-endpoint-1"
  target_resource_id         = azurerm_public_ip.example.id
  endpoint_status            = "Enabled"
  weight                     = 100
}

# Example: External Endpoint using the submodule
module "external_endpoint" {
  source = "../../modules/externalendpoints"

  traffic_manager_profile_id = module.test.resource_id
  name                       = "external-endpoint-1"
  target                     = "www.example.com"
  endpoint_status            = "Enabled"
  endpoint_location          = "East US"
  weight                     = 50
}

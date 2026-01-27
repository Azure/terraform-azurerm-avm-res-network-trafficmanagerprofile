terraform {
  required_version = "~> 1.5"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azapi" {}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.9"
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
  version = "~> 0.4"
}

# Random string for unique DNS name
resource "random_string" "dns_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create resource group using azapi
resource "azapi_resource" "resource_group" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
  type     = "Microsoft.Resources/resourceGroups@2024-03-01"
  body     = {}
}

# This is the module call
module "test" {
  source = "../../"

  dns_config = {
    relative_name = "avm-tm-${random_string.dns_suffix.result}"
    ttl           = 30
  }
  monitor_config = {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }
  name                   = module.naming.traffic_manager_profile.name_unique
  resource_group_name    = azapi_resource.resource_group.name
  traffic_routing_method = "Weighted"
  enable_telemetry       = var.enable_telemetry

  depends_on = [azapi_resource.resource_group]
}

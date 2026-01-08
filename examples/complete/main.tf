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
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
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

# Create a public IP for the Azure endpoint
resource "azapi_resource" "public_ip" {
  location  = azapi_resource.resource_group.location
  name      = module.naming.public_ip.name_unique
  parent_id = azapi_resource.resource_group.id
  type      = "Microsoft.Network/publicIPAddresses@2024-01-01"
  body = {
    properties = {
      publicIPAllocationMethod = "Static"
      publicIPAddressVersion   = "IPv4"
      dnsSettings = {
        domainNameLabel = "avm-pip-${random_string.dns_suffix.result}"
      }
    }
    sku = {
      name = "Standard"
      tier = "Regional"
    }
  }
  response_export_values = ["*"]
}

# Traffic Manager Profile with Weighted routing and multiple endpoint types
module "traffic_manager" {
  source = "../../"

  dns_config = {
    relative_name = "avm-tm-complete-${random_string.dns_suffix.result}"
    ttl           = 30
  }
  monitor_config = {
    protocol                     = "HTTPS"
    port                         = 443
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
    expected_status_code_ranges = [
      {
        min = 200
        max = 299
      }
    ]
  }
  name                   = module.naming.traffic_manager_profile.name_unique
  resource_group_name    = azapi_resource.resource_group.name
  traffic_routing_method = "Weighted"
  # Azure endpoint pointing to the public IP
  azure_endpoints = {
    "primary" = {
      name               = "azure-endpoint-primary"
      target_resource_id = azapi_resource.public_ip.id
      weight             = 100
      enabled            = true
    }
  }
  enable_telemetry = var.enable_telemetry
  # External endpoint pointing to an external website
  external_endpoints = {
    "external" = {
      name   = "external-endpoint-1"
      target = "www.example.com"
      weight = 50
    }
  }
  profile_status = "Enabled"

  depends_on = [azapi_resource.resource_group]
}

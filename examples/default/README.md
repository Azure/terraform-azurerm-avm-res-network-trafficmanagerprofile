<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
terraform {
  required_version = "~> 1.5"
}

# Creating a sample web app for use as an endpoint
resource "azurerm_service_plan" "example" {
  name                = "${module.naming.app_service_plan.name_unique}-example"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_web_app" "example1" {
  name                = "${module.naming.app_service.name_unique}-example1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}

resource "azurerm_windows_web_app" "example2" {
  name                = "${module.naming.app_service.name_unique}-example2"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}

# This is the module call
module "traffic_manager" {
  source              = "../../"
  name                = module.naming.traffic_manager_profile.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  traffic_routing_method = "Priority"
  profile_status         = "Enabled"
  ttl                    = 60

  monitor_config = {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
    expected_status_code_ranges  = ["200-299"]
  }

  endpoints = [
    {
      name               = "primary"
      endpoint_type      = "Azure"
      target_resource_id = azurerm_windows_web_app.example1.id
      priority           = 1
      endpoint_status    = "Enabled"
    },
    {
      name               = "secondary"
      endpoint_type      = "Azure"
      target_resource_id = azurerm_windows_web_app.example2.id
      priority           = 2
      endpoint_status    = "Enabled"
    }
  ]

  tags = {
    environment = "example"
    owner       = "terraform"
  }

  enable_telemetry = var.enable_telemetry
}

provider "azurerm" {
  features {}
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

# Creating a sample web app for use as an endpoint
resource "azurerm_service_plan" "example" {
  name                = "${module.naming.app_service_plan.name_unique}-example"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  os_type             = "Windows"
  sku_name            = "S1"
}

resource "azurerm_windows_web_app" "example1" {
  name                = "${module.naming.app_service.name_unique}-example1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}

resource "azurerm_windows_web_app" "example2" {
  name                = "${module.naming.app_service.name_unique}-example2"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {}
}

# This is the module call
module "traffic_manager" {
  source              = "../../"
  name                = module.naming.traffic_manager_profile.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  traffic_routing_method = "Priority"
  profile_status         = "Enabled"
  ttl                    = 60

  monitor_config = {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
    expected_status_code_ranges  = ["200-299"]
  }

  endpoints = [
    {
      name               = "primary"
      endpoint_type      = "Azure"
      target_resource_id = azurerm_windows_web_app.example1.id
      priority           = 1
      endpoint_status    = "Enabled"
    },
    {
      name               = "secondary"
      endpoint_type      = "Azure"
      target_resource_id = azurerm_windows_web_app.example2.id
      priority           = 2
      endpoint_status    = "Enabled"
    }
  ]

  tags = {
    environment = "example"
    owner       = "terraform"
  }

  enable_telemetry = var.enable_telemetry
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

## Resources

The following resources are used by this module:

- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_service_plan.example](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) (resource)
- [azurerm_windows_web_app.example1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) (resource)
- [azurerm_windows_web_app.example2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app) (resource)
- [random_integer.region_index](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: ~> 0.1

### <a name="module_traffic_manager"></a> [traffic\_manager](#module\_traffic\_manager)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-template

This is a template repo for Terraform Azure Verified Modules.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Search and update TODOs within the code and remove the TODO comments once complete.

> [!IMPORTANT]
> As the overall AVM framework is not GA (generally available) yet - the CI framework and test automation is not fully functional and implemented across all supported languages yet - breaking changes are expected, and additional customer feedback is yet to be gathered and incorporated. Hence, modules **MUST NOT** be published at version `1.0.0` or higher at this time.
>
> All module **MUST** be published as a pre-release version (e.g., `0.1.0`, `0.1.1`, `0.2.0`, etc.) until the AVM framework becomes GA.
>
> However, it is important to note that this **DOES NOT** mean that the modules cannot be consumed and utilized. They **CAN** be leveraged in all types of environments (dev, test, prod etc.). Consumers can treat them just like any other IaC module and raise issues or feature requests against them as they learn from the usage of the module. Consumers should also read the release notes for each version, if considering updating to a more recent version of a module to see if there are any considerations or breaking changes etc.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.29.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)
- [azurerm_traffic_manager_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/traffic_manager_endpoint) (resource)
- [azurerm_traffic_manager_profile.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/traffic_manager_profile) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Traffic Manager profile.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_customer_managed_key"></a> [customer\_managed\_key](#input\_customer\_managed\_key)

Description: A map describing customer-managed keys to associate with the resource. This includes the following properties:
- `key_vault_resource_id` - The resource ID of the Key Vault where the key is stored.
- `key_name` - The name of the key.
- `key_version` - (Optional) The version of the key. If not specified, the latest version is used.
- `user_assigned_identity` - (Optional) An object representing a user-assigned identity with the following properties:
  - `resource_id` - The resource ID of the user-assigned identity.

Type:

```hcl
object({
    key_vault_resource_id = string
    key_name              = string
    key_version           = optional(string, null)
    user_assigned_identity = optional(object({
      resource_id = string
    }), null)
  })
```

Default: `null`

### <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings)

Description: A map of diagnostic settings to create on the Traffic Manager Profile. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the diagnostic setting. One will be generated if not set, however this will not be unique if you want to create multiple diagnostic setting resources.
- `log_categories` - (Optional) A set of log categories to send to the log analytics workspace. Defaults to `[]`.
- `log_groups` - (Optional) A set of log groups to send to the log analytics workspace. Defaults to `["allLogs"]`.
- `metric_categories` - (Optional) A set of metric categories to send to the log analytics workspace. Defaults to `["AllMetrics"]`.
- `log_analytics_destination_type` - (Optional) The destination type for the diagnostic setting. Possible values are `Dedicated` and `AzureDiagnostics`. Defaults to `Dedicated`.
- `workspace_resource_id` - (Optional) The resource ID of the log analytics workspace to send logs and metrics to.
- `storage_account_resource_id` - (Optional) The resource ID of the storage account to send logs and metrics to.
- `event_hub_authorization_rule_resource_id` - (Optional) The resource ID of the event hub authorization rule to send logs and metrics to.
- `event_hub_name` - (Optional) The name of the event hub. If none is specified, the default event hub will be selected.
- `marketplace_partner_resource_id` - (Optional) The full ARM resource ID of the Marketplace resource to which you would like to send Diagnostic LogsLogs.

Type:

```hcl
map(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_endpoints"></a> [endpoints](#input\_endpoints)

Description: List of Traffic Manager endpoints.

Type:

```hcl
list(object({
    name                = string
    target_resource_id  = optional(string, null)
    target              = optional(string, null)
    endpoint_type       = string
    weight              = optional(number, null)
    priority            = optional(number, null)
    endpoint_location   = optional(string, null)
    endpoint_status     = optional(string, "Enabled")
    min_child_endpoints = optional(number, null)
    geo_mappings        = optional(list(string), [])
    subnets = optional(list(object({
      first = string
      last  = optional(string, null)
      scope = optional(number, null)
    })), [])
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
  }))
```

Default: `[]`

### <a name="input_max_return"></a> [max\_return](#input\_max\_return)

Description: The amount of endpoints to return for DNS queries to this Profile. Possible values range from 1 to 8. This argument is only valid for Traffic Manager profiles with routing\_method set to MultiValue.

Type: `number`

Default: `null`

### <a name="input_monitor_config"></a> [monitor\_config](#input\_monitor\_config)

Description: The endpoint monitoring configuration of the Traffic Manager profile.

Type:

```hcl
object({
    protocol                     = string
    port                         = number
    path                         = optional(string, null)
    interval_in_seconds          = optional(number, 30)
    timeout_in_seconds           = optional(number, 10)
    tolerated_number_of_failures = optional(number, 3)
    expected_status_code_ranges  = optional(list(string), [])
    custom_headers = optional(list(object({
      name  = string
      value = string
    })), [])
  })
```

Default:

```json
{
  "expected_status_code_ranges": [
    "200-299"
  ],
  "interval_in_seconds": 30,
  "path": "/",
  "port": 80,
  "protocol": "HTTP",
  "timeout_in_seconds": 10,
  "tolerated_number_of_failures": 3
}
```

### <a name="input_profile_status"></a> [profile\_status](#input\_profile\_status)

Description: The status of the Traffic Manager profile. Possible values are: Enabled and Disabled.

Type: `string`

Default: `"Enabled"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Tags to be applied to resources.

Type: `map(string)`

Default: `{}`

### <a name="input_traffic_routing_method"></a> [traffic\_routing\_method](#input\_traffic\_routing\_method)

Description: Specifies the traffic routing method of the Traffic Manager profile. Possible values are: Geographic, MultiValue, Performance, Priority, Subnet, Weighted.

Type: `string`

Default: `"Performance"`

### <a name="input_ttl"></a> [ttl](#input\_ttl)

Description: The DNS Time-To-Live (TTL), in seconds. Possible values include 30 to 999999.

Type: `number`

Default: `30`

## Outputs

The following outputs are exported:

### <a name="output_endpoints"></a> [endpoints](#output\_endpoints)

Description: A map of Traffic Manager endpoints.

### <a name="output_fqdn"></a> [fqdn](#output\_fqdn)

Description: The fully qualified domain name of the Traffic Manager profile.

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Traffic Manager profile.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Traffic Manager profile.

### <a name="output_profile_status"></a> [profile\_status](#output\_profile\_status)

Description: The status of the Traffic Manager profile.

### <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name)

Description: The name of the resource group in which the Traffic Manager profile is created.

### <a name="output_traffic_routing_method"></a> [traffic\_routing\_method](#output\_traffic\_routing\_method)

Description: The traffic routing method of the Traffic Manager profile.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->
# Nested Endpoints Submodule

This submodule creates a Nested Endpoint for a Traffic Manager Profile.

Nested Endpoints allow you to combine Traffic Manager profiles hierarchically, supporting complex routing scenarios for large multi-region, hybrid, or disaster recovery architectures.

## Usage

```hcl
module "nested_endpoint" {
  source = "../../modules/nestedendpoints"

  traffic_manager_profile_id = azapi_resource.parent_profile.id
  name                       = "my-nested-endpoint"
  target_resource_id         = azapi_resource.child_profile.id
  endpoint_status            = "Enabled"
  min_child_endpoints        = 1
}
```

# External Endpoints Submodule

This submodule creates an External Endpoint for a Traffic Manager Profile.

External Endpoints direct traffic to non-Azure resources identified by FQDN or IP address, such as on-premises sites or resources in other clouds.

## Usage

```hcl
module "external_endpoint" {
  source = "../../modules/externalendpoints"

  traffic_manager_profile_id = azapi_resource.traffic_manager_profile.id
  name                       = "my-external-endpoint"
  target                     = "www.example.com"
  endpoint_status            = "Enabled"
  weight                     = 50
}
```

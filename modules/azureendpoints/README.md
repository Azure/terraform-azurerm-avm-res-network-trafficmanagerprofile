# Azure Endpoints Submodule

This submodule creates an Azure Endpoint for a Traffic Manager Profile.

Azure Endpoints point to Azure-hosted resources such as App Services, VMs with Public IP addresses, or Cloud Services.

## Usage

```hcl
module "azure_endpoint" {
  source = "../../modules/azureendpoints"

  traffic_manager_profile_id = azapi_resource.traffic_manager_profile.id
  name                       = "my-azure-endpoint"
  target_resource_id         = azurerm_public_ip.example.id
  endpoint_status            = "Enabled"
  weight                     = 100
}
```

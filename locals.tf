locals {
  # Telemetry data collection
  built_with_avm = "azurerm/avm/latest"
  # Resource location from resource group if not specified explicitly
  location          = coalesce(var.location, data.azurerm_resource_group.this.location)
  module_name       = "avm-res-network-trafficmanagerprofile"
  module_version    = "1.0.0"
  telemetry_enabled = var.enable_telemetry
}

output "endpoints" {
  description = "A map of Traffic Manager endpoints."
  value = {
    for key, endpoint in azurerm_traffic_manager_endpoint.this : key => {
      id                 = endpoint.id
      name               = endpoint.name
      type               = endpoint.type
      target             = endpoint.target
      target_resource_id = endpoint.target_resource_id
      endpoint_status    = endpoint.endpoint_status
    }
  }
}

output "fqdn" {
  description = "The fully qualified domain name of the Traffic Manager profile."
  value       = azurerm_traffic_manager_profile.this.fqdn
}

output "id" {
  description = "The ID of the Traffic Manager profile."
  value       = azurerm_traffic_manager_profile.this.id
}

output "name" {
  description = "The name of the Traffic Manager profile."
  value       = azurerm_traffic_manager_profile.this.name
}

output "profile_status" {
  description = "The status of the Traffic Manager profile."
  value       = azurerm_traffic_manager_profile.this.profile_status
}

output "resource_group_name" {
  description = "The name of the resource group in which the Traffic Manager profile is created."
  value       = azurerm_traffic_manager_profile.this.resource_group_name
}

output "traffic_routing_method" {
  description = "The traffic routing method of the Traffic Manager profile."
  value       = azurerm_traffic_manager_profile.this.traffic_routing_method
}

output "azure_endpoints" {
  description = "A map of the Azure endpoints created."
  value       = module.azure_endpoints
}

output "external_endpoints" {
  description = "A map of the external endpoints created."
  value       = module.external_endpoints
}

output "fqdn" {
  description = "The fully-qualified domain name (FQDN) of the Traffic Manager profile."
  value       = azapi_resource.this.output.properties.dnsConfig.fqdn
}

output "id" {
  description = "The resource ID of the Traffic Manager profile."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the Traffic Manager profile."
  value       = azapi_resource.this.name
}

output "nested_endpoints" {
  description = "A map of the nested endpoints created."
  value       = module.nested_endpoints
}

output "resource_id" {
  description = "The resource ID of the Traffic Manager profile."
  value       = azapi_resource.this.id
}

output "id" {
  description = "The resource ID of the nested endpoint."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the nested endpoint."
  value       = azapi_resource.this.name
}

output "endpoint_location" {
  description = "The endpoint location returned by Azure."
  value       = azapi_resource.this.output.properties.endpointLocation
}

output "priority" {
  description = "The endpoint priority returned by Azure."
  value       = azapi_resource.this.output.properties.priority
}

output "resource_id" {
  description = "The resource ID of the nested endpoint."
  value       = azapi_resource.this.id
}

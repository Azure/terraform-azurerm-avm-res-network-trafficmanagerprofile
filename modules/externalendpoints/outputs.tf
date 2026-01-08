output "resource" {
  description = "The External Endpoint resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the External Endpoint."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the External Endpoint."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The Nested Endpoint resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the Nested Endpoint."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the Nested Endpoint."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The Azure Endpoint resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the Azure Endpoint."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the Azure Endpoint."
  value       = azapi_resource.this.name
}

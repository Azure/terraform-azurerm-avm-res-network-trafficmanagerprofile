output "id" {
  description = "The resource ID of the Azure endpoint."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the Azure endpoint."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The Azure endpoint resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the Azure endpoint."
  value       = azapi_resource.this.id
}

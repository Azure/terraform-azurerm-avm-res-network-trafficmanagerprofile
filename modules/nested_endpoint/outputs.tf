output "id" {
  description = "The resource ID of the nested endpoint."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the nested endpoint."
  value       = azapi_resource.this.name
}

output "resource" {
  description = "The nested endpoint resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the nested endpoint."
  value       = azapi_resource.this.id
}

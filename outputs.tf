output "resource" {
  description = "The Traffic Manager Profile resource."
  value       = azapi_resource.this
}

output "resource_id" {
  description = "The resource ID of the Traffic Manager Profile."
  value       = azapi_resource.this.id
}

output "name" {
  description = "The name of the Traffic Manager Profile."
  value       = azapi_resource.this.name
}

output "fqdn" {
  description = "The FQDN of the Traffic Manager Profile."
  value       = jsondecode(azapi_resource.this.output).properties.dnsConfig.fqdn
}

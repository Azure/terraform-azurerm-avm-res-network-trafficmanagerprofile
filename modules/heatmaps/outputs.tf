output "heat_map_data" {
  description = "The heat map data for the Traffic Manager Profile."
  value       = jsondecode(data.azapi_resource.this.output)
}

output "endpoints" {
  description = "The endpoints included in the heat map."
  value       = try(jsondecode(data.azapi_resource.this.output).properties.endpoints, [])
}

output "start_time" {
  description = "The start time of the heat map data collection period."
  value       = try(jsondecode(data.azapi_resource.this.output).properties.startTime, null)
}

output "end_time" {
  description = "The end time of the heat map data collection period."
  value       = try(jsondecode(data.azapi_resource.this.output).properties.endTime, null)
}

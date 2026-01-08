variable "traffic_manager_profile_id" {
  type        = string
  description = "The resource ID of the Traffic Manager Profile."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the External Endpoint."
  nullable    = false
}

variable "target" {
  type        = string
  description = "The FQDN or IP address of the external endpoint."
  nullable    = false
}

variable "endpoint_status" {
  type        = string
  default     = "Enabled"
  description = "The status of the endpoint. Possible values are 'Enabled' and 'Disabled'."
  nullable    = false

  validation {
    condition     = contains(["Enabled", "Disabled"], var.endpoint_status)
    error_message = "Endpoint status must be either 'Enabled' or 'Disabled'."
  }
}

variable "weight" {
  type        = number
  default     = null
  description = "The weight of the endpoint for weighted routing. Value must be between 1 and 1000."

  validation {
    condition     = var.weight == null || (var.weight >= 1 && var.weight <= 1000)
    error_message = "Weight must be between 1 and 1000 when specified."
  }
}

variable "priority" {
  type        = number
  default     = null
  description = "The priority of the endpoint for priority routing. Value must be between 1 and 1000."

  validation {
    condition     = var.priority == null || (var.priority >= 1 && var.priority <= 1000)
    error_message = "Priority must be between 1 and 1000 when specified."
  }
}

variable "endpoint_location" {
  type        = string
  default     = null
  description = "The location of the endpoint. Required for Performance routing method."
}

variable "min_child_endpoints" {
  type        = number
  default     = null
  description = "The minimum number of endpoints that must be available in the child profile for the parent profile to be considered available."

  validation {
    condition     = var.min_child_endpoints == null || var.min_child_endpoints >= 1
    error_message = "Minimum child endpoints must be at least 1 when specified."
  }
}

variable "geo_mapping" {
  type        = list(string)
  default     = null
  description = "The list of geographic locations mapped to the endpoint for Geographic routing."
}

variable "subnets" {
  type = list(object({
    first = string
    last  = optional(string, null)
    scope = optional(number, null)
  }))
  default     = null
  description = "The list of subnet mappings for Subnet routing."
}

variable "custom_headers" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = null
  description = "The list of custom headers to be sent with health checks."
}

variable "endpoint_monitor_status" {
  type        = string
  default     = null
  description = "The monitoring status of the endpoint."
}

variable "always_serve" {
  type        = string
  default     = null
  description = "Whether the endpoint should always be served. Possible values are 'Enabled' and 'Disabled'."

  validation {
    condition     = var.always_serve == null || contains(["Enabled", "Disabled"], var.always_serve)
    error_message = "Always serve must be either 'Enabled' or 'Disabled' when specified."
  }
}

variable "timeouts" {
  type = object({
    create = optional(string, null)
    delete = optional(string, null)
    read   = optional(string, null)
    update = optional(string, null)
  })
  default     = null
  description = "Timeout configuration for the External Endpoint resource operations."
}

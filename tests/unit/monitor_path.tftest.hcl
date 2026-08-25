mock_provider "azapi" {
  mock_data "azapi_client_config" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000001"
    }
  }

  mock_resource "azapi_resource" {
    defaults = {
      output = {
        properties = {
          dnsConfig = {
            fqdn = "tm-unit-test.trafficmanager.net"
          }
        }
      }
    }
  }
}
mock_provider "modtm" {}
mock_provider "random" {}

variables {
  dns_config = {
    relative_name = "tm-unit-test"
    ttl           = 30
  }
  enable_telemetry       = false
  name                   = "tm-unit-test"
  resource_group_name    = "rg-unit-test"
  traffic_routing_method = "Performance"
}

run "tcp_monitor_omits_path" {
  command = apply

  variables {
    monitor_config = {
      protocol = "TCP"
      port     = 443
      path     = null
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.monitorConfig.path == null
    error_message = "TCP monitor requests must set path to null so AzAPI omits it from the request body."
  }

  assert {
    condition     = azapi_resource.this.ignore_null_property
    error_message = "AzAPI must ignore null properties so the TCP monitor path is omitted."
  }
}

run "http_monitor_defaults_path" {
  command = apply

  variables {
    monitor_config = {
      protocol = "HTTP"
      port     = 80
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.monitorConfig.path == "/"
    error_message = "HTTP monitor requests must retain the default path of '/'."
  }
}

run "https_monitor_preserves_path" {
  command = apply

  variables {
    monitor_config = {
      protocol = "HTTPS"
      port     = 443
      path     = "/health"
    }
  }

  assert {
    condition     = azapi_resource.this.body.properties.monitorConfig.path == "/health"
    error_message = "HTTPS monitor requests must retain an explicitly configured path."
  }
}

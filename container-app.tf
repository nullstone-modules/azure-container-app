resource "azurerm_log_analytics_workspace" "this" {
  name                = local.resource_name
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

resource "azurerm_container_app_environment" "this" {
  name                       = local.resource_name
  location                   = var.location
  resource_group_name        = local.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  infrastructure_subnet_id   = local.private_subnet_ids[0]
  tags                       = local.tags
}

resource "azurerm_container_app" "this" {
  name                         = local.resource_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = local.resource_group_name
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  // Configure ACR registry if using managed image
  dynamic "registry" {
    for_each = var.image_url == "" ? [1] : []

    content {
      server   = azurerm_container_registry.this[0].login_server
      identity = azurerm_user_assigned_identity.app.id
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "main"
      image  = "${local.repository_url}:${local.app_version}"
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = local.all_env_vars

        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = local.all_secret_refs

        content {
          name        = env.key
          secret_name = env.value
        }
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = var.container_port
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  // Secrets for the container app (referenced by env vars)
  dynamic "secret" {
    for_each = local.managed_secret_values

    content {
      name  = lower(replace(secret.key, "/[^a-z0-9-]/", "-"))
      value = secret.value
    }
  }
}

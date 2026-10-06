variable "env_vars" {
  type        = map(string)
  default     = {}
  description = <<EOF
The environment variables to inject into the container app.
These are typically used to configure a service per environment.
EOF
}

variable "secrets" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = <<EOF
The sensitive environment variables to inject into the container app.
EOF
}

locals {
  standard_env_vars = tomap({
    NULLSTONE_STACK         = data.ns_workspace.this.stack_name
    NULLSTONE_APP           = data.ns_workspace.this.block_name
    NULLSTONE_ENV           = data.ns_workspace.this.env_name
    NULLSTONE_VERSION       = data.ns_app_env.this.version
    NULLSTONE_COMMIT_SHA    = data.ns_app_env.this.commit_sha
    NULLSTONE_PUBLIC_HOSTS  = join(",", local.public_hosts)
    NULLSTONE_PRIVATE_HOSTS = join(",", local.private_hosts)
  })
  azure_env_vars = tomap({
    AZURE_SUBSCRIPTION_ID = local.subscription_id
    AZURE_CLIENT_ID       = azurerm_user_assigned_identity.app.client_id
  })

  // Container Apps injects these into every container; they are reported, not added to the container app
  platform_env_vars = tomap({
    CONTAINER_APP_NAME           = local.resource_name
    CONTAINER_APP_ENV_DNS_SUFFIX = azurerm_container_app_environment.this.default_domain
  })
  cloud_env_vars = merge(local.azure_env_vars, local.platform_env_vars)
}

// ns_env_layout classifies secrets using keys only, so the set of secrets to add to the container app is known at plan time
data "ns_env_layout" "this" {
  platform         = "azure_container_app"
  standard_keys    = keys(local.standard_env_vars)
  cloud_keys       = keys(local.cloud_env_vars)
  user_env         = var.env_vars
  user_secret_keys = nonsensitive(keys(var.secrets))
}

data "ns_env_values" "this" {
  platform     = "azure_container_app"
  standard     = local.standard_env_vars
  cloud        = local.cloud_env_vars
  user_env     = var.env_vars
  user_secrets = var.secrets
}

// ns_env_platform_data records where each managed secret lives so Nullstone can display the environment
data "ns_env_platform_data" "this" {
  values     = data.ns_env_values.this.platform_data
  secret_ids = local.secret_names
}

locals {
  // Map of env_var_name => secret_name (lowercased and sanitized for Container Apps)
  secret_names = { for key in data.ns_env_layout.this.managed_secret_keys : key => lower(replace(key, "/[^a-z0-9-]/", "-")) }

  // A platform variable reaches the container app only when the user overrides it
  container_env_vars = {
    for k, v in data.ns_env_values.this.env_variables : k => v
    if !(contains(keys(local.platform_env_vars), k) && data.ns_env_values.this.sources[k] == "cloud")
  }
}

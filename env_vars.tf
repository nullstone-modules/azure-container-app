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

  input_env_vars = merge(local.standard_env_vars, local.azure_env_vars, var.env_vars)
}

data "ns_env_variables" "this" {
  input_env_variables = local.input_env_vars
  input_secrets       = var.secrets
}

locals {
  all_env_vars          = data.ns_env_variables.this.env_variables
  managed_secret_values = data.ns_env_variables.this.secrets

  // Map of env_var_name => secret_name (lowercased and sanitized for Container Apps)
  all_secret_refs = { for key in keys(local.managed_secret_values) : key => lower(replace(key, "/[^a-z0-9-]/", "-")) }
}

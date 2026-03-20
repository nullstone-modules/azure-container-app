output "container_app_id" {
  value       = azurerm_container_app.this.id
  description = "string ||| The ID of the Azure Container App."
}

output "container_app_name" {
  value       = azurerm_container_app.this.name
  description = "string ||| The name of the Azure Container App."
}

output "container_app_fqdn" {
  value       = try(azurerm_container_app.this.ingress[0].fqdn, "")
  description = "string ||| The FQDN of the Azure Container App."
}

output "image_repo_url" {
  value       = local.repository_url
  description = "string ||| Container image url."
}

output "log_provider" {
  value       = "azuremonitor"
  description = "string ||| The log provider used for this service."
}

output "deployer" {
  value = {
    subscription_id = local.subscription_id
    client_id       = try(azurerm_user_assigned_identity.deployer.client_id, "")
  }

  description = "object({ subscription_id: string, client_id: string }) ||| An Azure identity with explicit privilege to deploy this container app."
}

output "image_pusher" {
  value = {
    subscription_id = local.subscription_id
    client_id       = try(azurerm_user_assigned_identity.image_pusher.client_id, "")
  }

  description = "object({ subscription_id: string, client_id: string }) ||| An Azure identity that is allowed to push images."
}

output "private_urls" {
  value       = local.private_urls
  description = "list(string) ||| A list of URLs only accessible inside the network"
}

output "public_urls" {
  value       = local.public_urls
  description = "list(string) ||| A list of URLs accessible to the public"
}

resource "azurerm_user_assigned_identity" "app" {
  name                = local.resource_name
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

// Allow the app identity to pull images from ACR
resource "azurerm_role_assignment" "app_acr_pull" {
  count = var.image_url == "" ? 1 : 0

  scope                = azurerm_container_registry.this[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

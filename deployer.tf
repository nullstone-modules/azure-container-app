resource "azurerm_user_assigned_identity" "deployer" {
  name                = "deployer-${local.resource_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  tags                = local.tags
}

resource "azurerm_role_assignment" "deployer_container_app_contributor" {
  scope                = azurerm_container_app.this.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.deployer.principal_id
}

locals {
  private_urls = []
  public_urls  = azurerm_container_app.this.ingress[0].fqdn != "" ? ["https://${azurerm_container_app.this.ingress[0].fqdn}"] : []

  uri_matcher       = "^(?:(?P<scheme>[^:/?#]+):)?(?://(?P<authority>[^/?#]*))?"
  authority_matcher = "^(?:(?P<user>[^@]*)@)?(?:(?P<host>[^:]*))(?:[:](?P<port>[\\d]*))?"

  public_hosts  = [for url in local.public_urls : lookup(regex(local.authority_matcher, lookup(regex(local.uri_matcher, url), "authority")), "host") if url != ""]
  private_hosts = []
}

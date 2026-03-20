data "ns_connection" "network" {
  name     = "network"
  contract = "network/azure/vnet"
}

locals {
  vnet_id            = data.ns_connection.network.outputs.vnet_id
  private_subnet_ids = data.ns_connection.network.outputs.private_subnet_ids
}

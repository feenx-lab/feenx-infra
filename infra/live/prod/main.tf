# Locals
locals {
  bootstrap_node = one([for n in var.talos_nodes : n.hostname if n.bootstrap])
}

# Modules
module "flint_pxe" {
  source         = "../../modules/flint_pxe"
  network_subnet = "10.10.97.1/24"
  wait_time      = 180
  talos_nodes    = var.talos_nodes
}
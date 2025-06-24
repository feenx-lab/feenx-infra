# Locals
locals {
  bootstrap_node = one([for n in var.cluster_nodes : n.hostname if n.bootstrap])
}

# Modules
module "baremetal" {
  source         = "../../modules/baremetal"
  network_subnet = "10.10.97.1/24"
  wait_time      = 180
  cluster_nodes    = var.cluster_nodes
}

module "foundation" {
  depends_on = [module.baremetal]
  source = "../../modules/foundation"
  cluster_info = var.cluster_info
  cluster_nodes = var.cluster_nodes
  talos_version = module.baremetal.talos_version
  schematic_id = module.baremetal.schematic_id
}
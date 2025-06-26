# Locals
locals {
  bootstrap_node = one([for n in var.cluster_nodes : n.hostname if n.bootstrap])
  inline_manifests = [
    {
      name     = "cilium"
      contents = module.config.cilium_manifest
    }
  ]
}

# Modules

# Makes sure that our nodes are booted up,
# and in the talos maintenance mode,
# ready to be configured.
module "baremetal" {
  source            = "../../modules/baremetal"
  network_subnet    = "10.10.97.1/24"
  wait_time         = 180
  wol_mac_addresses = [for n in var.cluster_nodes : n.wake_on_lan_mac]
}

# Prepares all the configs
module "config" {
  depends_on     = [module.baremetal]
  source         = "../../modules/config"
  cluster_name   = var.cluster_info.name
  node_names     = [for n in var.cluster_nodes : n.hostname]                       #TODO: Create as local
  node_ips       = [for n in var.cluster_nodes : n.ip if n.role == "controlplane"] #TODO: Create as local
  cilium_version = "1.17.5"                                                        #TODO: Create variable in the root module.
  k8s_version    = "1.33.0"                                                        #TODO: Create variable in the root module.
  talos_version  = module.baremetal.talos_version
}

# Hack to allow the use of dependencies between each node
# This way destroying the cluster should result in at least one node left at all time
# without getting an error when trying to destroy the last node (because it will wait for the other ones)
module "nx0" {
  depends_on = [module.baremetal]
  source     = "../../modules/node"

  # Cluster Info
  cluster_info  = var.cluster_info
  talos_version = module.baremetal.talos_version
  k8s_version   = "1.33.0" #TODO: Create variable in the root module.
  schematic_id  = module.baremetal.schematic_id

  # Node Info
  node_info = var.cluster_nodes["nx0"]

  # Config Info
  machine_secrets      = module.config.machine_secrets
  client_configuration = module.config.client_configuration

  # Inline Manifests
  inline_manifests = local.inline_manifests
}

module "nx1" {
  depends_on = [module.baremetal, module.nx0]
  source     = "../../modules/node"

  # Cluster Info
  cluster_info  = var.cluster_info
  talos_version = module.baremetal.talos_version
  k8s_version   = "1.33.0" #TODO: Create variable in the root module.
  schematic_id  = module.baremetal.schematic_id

  # Node Info
  node_info = var.cluster_nodes["nx1"]

  # Config Info
  machine_secrets      = module.config.machine_secrets
  client_configuration = module.config.client_configuration

  # Inline Manifests
  inline_manifests = local.inline_manifests
}

module "nx2" {
  depends_on = [module.baremetal, module.nx0]
  source     = "../../modules/node"

  # Cluster Info
  cluster_info  = var.cluster_info
  talos_version = module.baremetal.talos_version
  k8s_version   = "1.33.0" #TODO: Create variable in the root module.
  schematic_id  = module.baremetal.schematic_id

  # Node Info
  node_info = var.cluster_nodes["nx2"]

  # Config Info
  machine_secrets      = module.config.machine_secrets
  client_configuration = module.config.client_configuration

  # Inline Manifests
  inline_manifests = local.inline_manifests
}

# Bootstrap the cluster, get kubeconfig
module "cluster" {
  depends_on = [module.nx0, module.nx1, module.nx2]
  source     = "../../modules/cluster"

  # Config Info
  client_configuration = module.config.client_configuration

  cluster_nodes = var.cluster_nodes
}
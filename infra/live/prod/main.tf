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

# Data
data "local_sensitive_file" "kube_config"{
  depends_on = [module.cluster]
  filename   = pathexpand(var.kube_config_path)
}

# Modules
module "baremetal" {
  source            = "../../modules/baremetal"
  network_subnet    = "10.10.97.1/24"
  wait_time         = 180
  wol_mac_addresses = [for n in var.cluster_nodes : n.wake_on_lan_mac]
}

module "config" {
  # depends_on     = [module.baremetal]
  source         = "../../modules/config"
  cluster_name   = var.cluster_info.name
  node_names     = [for n in var.cluster_nodes : n.hostname]                       #TODO: Create as local
  node_ips       = [for n in var.cluster_nodes : n.ip if n.role == "controlplane"] #TODO: Create as local
  cilium_version = "1.17.5"                                                        #TODO: Create variable in the root module.
  k8s_version   = var.k8s_version
  talos_version  = module.baremetal.talos_version
}

module "nx0" {
  depends_on = [module.baremetal]
  source     = "../../modules/node"

  # Cluster Info
  cluster_info  = var.cluster_info
  talos_version = module.baremetal.talos_version
  k8s_version   = var.k8s_version
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
  k8s_version   = var.k8s_version
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
  k8s_version   = var.k8s_version
  schematic_id  = module.baremetal.schematic_id

  # Node Info
  node_info = var.cluster_nodes["nx2"]

  # Config Info
  machine_secrets      = module.config.machine_secrets
  client_configuration = module.config.client_configuration

  # Inline Manifests
  inline_manifests = local.inline_manifests
}

module "cluster" {
  depends_on = [module.nx0, module.nx1, module.nx2]
  source     = "../../modules/cluster"

  # Config Info
  client_configuration = module.config.client_configuration
  kube_config_path = var.kube_config_path

  cluster_nodes = var.cluster_nodes
}

module "github_deploy_key" {
  depends_on = [module.cluster]
  source = "../../modules/github_deploy_key"
  full_repo_name = "feenx-lab/feenx-platform"
}

module "flux_operator" {
  depends_on = [module.github_deploy_key]
  source = "../../modules/flux_operator"
  git_url = "ssh://git@github.com:feenx-lab/feenx-platform.git"
  git_path = "apps"
  git_private_key = module.github_deploy_key.tls_private_key
  providers = {
    kubernetes = kubernetes.configured
    helm = helm.configured
  }
}
# Locals
locals {
  controlplane_nodes  = [for n in var.cluster_nodes : n if n.role == "controlplane"]
  bootstrap_node_ip   = local.controlplane_nodes[0].ip
  bootstrap_node_name = local.controlplane_nodes[0].hostname
}

# Data
# https://github.com/siderolabs/terraform-provider-talos/issues/206
data "talos_cluster_health" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = var.client_configuration
  control_plane_nodes  = [for n in local.controlplane_nodes : n.ip]
  endpoints            = [for n in var.cluster_nodes : n.hostname]
}

# Resources
resource "talos_machine_bootstrap" "this" {
  node                 = local.bootstrap_node_ip
  endpoint             = local.bootstrap_node_ip
  client_configuration = var.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  client_configuration = var.client_configuration
  node                 = local.bootstrap_node_ip
}

resource "local_file" "kubeconfig" {
  depends_on = [talos_cluster_kubeconfig.this]
  content    = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename   = pathexpand("~/.kube/config")
}
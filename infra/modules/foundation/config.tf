# Data
data "talos_client_configuration" "this" {
  cluster_name = var.cluster_info.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes = [for n in var.cluster_nodes : n.hostname]
  endpoints = [for n in var.cluster_nodes : n.ip if n.role == "controlplane"]
}

data "talos_machine_configuration" "this" {
  for_each = var.cluster_nodes
  cluster_name = var.cluster_info.name
  cluster_endpoint = var.cluster_info.endpoint
  machine_secrets = talos_machine_secrets.this.machine_secrets

  machine_type = each.value.role
  talos_version = var.talos_version
  config_patches = [
    templatefile("${path.module}/templates/controlplane.yaml.tftpl", {
      hostname = each.value.hostname
      mac_address = lower(each.value.mac_address)
      wake_on_lan_mac = lower(each.value.wake_on_lan_mac)
      install_disk = each.value.install_disk
      virtual_ip = var.cluster_info.virtual_ip
      talos_version = var.talos_version
      schematic_id = var.schematic_id
    })
  ]
}

# Resources
resource "talos_machine_secrets" "this" {}
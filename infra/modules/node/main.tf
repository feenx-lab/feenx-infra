# Data
data "talos_machine_configuration" "this" {
  # Cluster Configuration
  cluster_name     = var.cluster_info.name
  cluster_endpoint = var.cluster_info.endpoint

  # Machine Configuration
  talos_version      = var.talos_version
  kubernetes_version = var.k8s_version
  machine_type       = var.node_info.role
  machine_secrets    = var.machine_secrets

  config_patches = [
    # Generate controlplane config
    templatefile("${path.module}/templates/controlplane.yaml.tftpl", {
      hostname        = var.node_info.hostname
      mac_address     = lower(var.node_info.mac_address)
      wake_on_lan_mac = lower(var.node_info.wake_on_lan_mac)
      install_disk    = var.node_info.install_disk
      virtual_ip      = var.cluster_info.virtual_ip
      talos_version   = var.talos_version
      schematic_id    = var.schematic_id
    }),

    # Install Cilium CNI using inline manifests
    yamlencode({
      cluster = {
        inlineManifests = var.inline_manifests
      }
    })
  ]
}

# Resources
resource "talos_machine_configuration_apply" "this" {
  client_configuration = var.client_configuration

  endpoint                    = var.node_info.ip
  node                        = var.node_info.hostname
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration

  on_destroy = {
    # Controls wether we can destroy the entire cluster or not,
    # if graceful, a full destroy of all nodes will fail on a node because its the last member of the cluster
    # otherwise, will destroy all nodes regardless of the cluster health, members, etc.
    graceful = true

    # Let's not reset and reboot anymore, we have real stuff on the cluster now!
    reset    = false
    reboot   = false
  }
}
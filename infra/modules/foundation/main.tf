# Locals
locals {
  bootstrap_node_ip = [for n in var.cluster_nodes : n.ip if n.role == "controlplane"][0]
}

# Resources
resource "talos_machine_configuration_apply" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration

  for_each = data.talos_machine_configuration.this
  node = each.key
  endpoint = var.cluster_nodes[each.key].ip
  machine_configuration_input = each.value.machine_configuration

  on_destroy = {
    graceful = false
    reset = true
    reboot = true
  }
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [talos_machine_configuration_apply.this]
  node = local.bootstrap_node_ip
  endpoint = local.bootstrap_node_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}
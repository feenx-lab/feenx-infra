output "machine_secrets" {
  value = talos_machine_secrets.this.machine_secrets
}

output "client_configuration" {
  value = talos_machine_secrets.this.client_configuration
}

output "cilium_manifest" {
  value = data.helm_template.cilium.manifest
}
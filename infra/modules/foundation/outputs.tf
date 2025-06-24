output "talos_config" {
  sensitive = true
  value = data.talos_client_configuration.this.talos_config
}
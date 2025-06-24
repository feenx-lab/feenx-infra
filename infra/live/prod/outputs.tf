output "talos_config" {
  sensitive = true
  value = module.foundation.talos_config
}
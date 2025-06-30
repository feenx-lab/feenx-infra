output "talos_version" {
  value = tostring(local.talos_version)
}

output "schematic_id" {
  value = talos_image_factory_schematic.this.id
}
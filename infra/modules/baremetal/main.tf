# Locals
locals {
  factory_base_url     = "https://factory.talos.dev"
  talos_version_latest = element(data.talos_image_factory_versions.this.talos_versions, length(data.talos_image_factory_versions.this.talos_versions) - 1)
  talos_version        = coalesce(var.talos_version, local.talos_version_latest)
  base_args = [
    "--wait", var.wait_time,
    "--talos-version", local.talos_version,
    "--schematic-id", talos_image_factory_schematic.this.id,
    "--network", var.network_subnet
  ]
  wol_args       = flatten([for mac in var.wol_mac_addresses : ["-m", mac]])
  flint_pxe_args = concat(local.base_args, local.wol_args)
}

# Data
data "talos_image_factory_versions" "this" {
  filters = {
    stable_versions_only = true
  }
}

data "talos_image_factory_extensions_versions" "this" {
  talos_version = local.talos_version
  filters = {
    names = [
      "amdgpu"
    ]
  }
}

data "docker_registry_image" "flint_pxe_registry_image" {
  name = "ghcr.io/feenx-lab/flint-pxe:latest" #TODO: Lock version
}

# Resources
resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info.*.name
        }
      }
    }
  )
}

resource "docker_image" "flint_pxe_image" {
  name          = data.docker_registry_image.flint_pxe_registry_image.name
  pull_triggers = [data.docker_registry_image.flint_pxe_registry_image.sha256_digest]
}

resource "docker_container" "flint_pxe_container" {
  name         = "ephemeral-flint-pxe"
  image        = docker_image.flint_pxe_image.image_id
  start        = true
  network_mode = "host"
  capabilities {
    add = [
      "NET_ADMIN"
    ]
  }

  command = local.flint_pxe_args
}
variable "node_info" {
  type = object({
    hostname        = string
    ip              = string
    mac_address     = string
    wake_on_lan_mac = string
    install_disk    = string
    role            = string
    bootstrap       = optional(bool, false)
  })
}

variable "cluster_info" {
  description = "Cluster Information"
  type = object({
    name        = string
    virtual_ip  = string
    nameservers = list(string)
    endpoint    = string
  })
}

variable "talos_version" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "machine_secrets" {
  type = any
}

variable "client_configuration" {
  type = any
}

variable "inline_manifests" {
  type = list(object({
    name     = string
    contents = string
  }))
}

variable "schematic_id" {
  type = string
}
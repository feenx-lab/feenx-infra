variable "cluster_nodes" {
  type = map(object({
    hostname        = string
    ip              = string
    mac_address     = string
    wake_on_lan_mac = string
    install_disk    = string
    role            = string
    bootstrap       = optional(bool, false)
  }))
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

variable "schematic_id" {
  type = string
}
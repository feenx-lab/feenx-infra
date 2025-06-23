variable "talos_nodes" {
  type = map(object({
    hostname        = string
    mac_address     = string
    wake_on_lan_mac = string
    install_disk    = string
    bootstrap       = optional(bool, false)
  }))
}
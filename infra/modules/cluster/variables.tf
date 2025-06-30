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

variable "client_configuration" {
  type = any
}

variable "kube_config_path" {
  type = string
}
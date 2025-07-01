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

variable "k8s_version" {
  type = string
}

variable "kube_config_path" {
  type = string
  default = "~/.kube/config"
}

variable "github_organization" {
  type = string
}

variable "github_repository" {
  type = string
}
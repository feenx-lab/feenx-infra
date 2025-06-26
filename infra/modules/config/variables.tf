variable "cluster_name" {
  type = string
}

variable "node_names" {
  type = list(string)
}

variable "node_ips" {
  type = list(string)
}

variable "cilium_version" {
  type = string
}

variable "k8s_version" {
  type = string
}

variable "talos_version" {
  type = string
}
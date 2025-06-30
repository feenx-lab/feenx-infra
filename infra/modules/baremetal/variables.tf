variable "talos_platform" {
  description = "Platform to use to get the talos iPXE"
  type        = string
  nullable    = true
  default     = null
}

variable "talos_version" {
  description = "Version to use for Talos' image, format: vX.Y.Z"
  type        = string
  nullable    = true
  default     = null

  validation {
    condition     = var.talos_version == null ? true : can(regex("^v[0-9]+.[0-9]+.[0-9]+"), var.talos_version)
    error_message = "talos_version needs to be prefixed with 'v', e.g 'v10.1.4' is valid, '10.1.4' is invalid"
  }
}

variable "talos_architecture" {
  description = "Architecture to be used for the Talos Image Factory"
  type        = string
  nullable    = true
  default     = null
}

variable "network_subnet" {
  description = "CIDR notation of the DHCP server present in your network, e.g 192.168.1.1/24"
  type        = string
}

variable "wait_time" {
  description = "How much time to wait (in seconds), for the flint-pxe to auto-shutdown"
  type        = number
}

variable "wol_mac_addresses" {
  description = "List of mac addresses to wake on lan for bootstrapping"
  type        = list(string)
}
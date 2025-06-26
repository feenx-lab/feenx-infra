cluster_nodes = {
  nx0 = {
    hostname        = "nx0.feenx.io"
    ip              = "10.10.97.10"
    mac_address     = "58:47:CA:7F:E2:16"
    wake_on_lan_mac = "58:47:CA:7F:E2:14"
    install_disk    = "/dev/nvme0n1"
    role            = "controlplane"
    bootstrap       = true
  },
  nx1 = {
    hostname        = "nx1.feenx.io"
    ip              = "10.10.97.11"
    mac_address     = "58:47:CA:7F:D3:B6"
    wake_on_lan_mac = "58:47:CA:7F:D3:B4"
    install_disk    = "/dev/nvme0n1"
    role            = "controlplane"
    depends_on      = ["nx0"]
  },
  nx2 = {
    hostname        = "nx2.feenx.io"
    ip              = "10.10.97.12"
    mac_address     = "58:47:CA:7F:D7:7E"
    wake_on_lan_mac = "58:47:CA:7F:D7:7C"
    install_disk    = "/dev/nvme0n1"
    role            = "controlplane"
    depends_on      = ["nx1"]
  }
}

cluster_info = {
  name        = "fnx-platform-prod-k8s"
  nameservers = ["10.10.97.254"]
  virtual_ip  = "10.10.97.20"
  endpoint    = "https://k8s.feenx.io:6443"
}
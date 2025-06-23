talos_nodes = {
  nx0 = {
    hostname        = "nx0.feenx.io"
    mac_address     = "58:47:CA:7F:E2:16"
    wake_on_lan_mac = "58:47:CA:7F:E2:14"
    install_disk    = "/dev/nvme0n1"
    role            = "controlplane"
    bootstrap       = true
  },
  nx1 = {
    hostname        = "nx1.feenx.io"
    mac_address     = "58:47:CA:7F:D3:B6"
    wake_on_lan_mac = "58:47:CA:7F:D3:B4"
    install_disk    = "/dev/nvme0n1"
    role            = "controlplane"
  },
  nx2 = {
    hostname        = "nx2.feenx.io"
    mac_address     = "58:47:CA:7F:D7:7E"
    wake_on_lan_mac = "58:47:CA:7F:D7:7C"
    install_disk    = "/dev/nvme0n1"
    role            = "controlplane"
  }
}
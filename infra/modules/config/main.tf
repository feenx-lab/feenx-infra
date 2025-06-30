# Data
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = var.node_names
  endpoints            = var.node_ips
}

data "helm_template" "cilium" {
  name         = "cilium"
  repository   = "https://helm.cilium.io/"
  chart        = "cilium"
  version      = var.cilium_version
  kube_version = var.k8s_version

  create_namespace = true
  namespace        = "kube-system"

  set = [
    { name = "ipam.mode", value = "kubernetes" },
    { name = "kubeProxyReplacement", value = "true" },
    { name = "securityContext.capabilities.ciliumAgent", value = "{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" },
    { name = "securityContext.capabilities.cleanCiliumState", value = "{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" },
    { name = "cgroup.autoMount.enabled", value = "false" },
    { name = "cgroup.hostRoot", value = "/sys/fs/cgroup" },
    { name = "k8sServiceHost", value = "localhost" },
    { name = "k8sServicePort", value = "7445" },
    { name = "gatewayAPI.enabled", value = "true" },
    { name = "gatewayAPI.enableAlpn", value = "true" },
    { name = "gatewayAPI.enableAppProtocol", value = "true" },
  ]
}

# Resources
resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

resource "local_sensitive_file" "talos_config" {
  content  = data.talos_client_configuration.this.talos_config
  filename = pathexpand("~/.talos/config")
}
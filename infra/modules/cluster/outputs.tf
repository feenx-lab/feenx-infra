output "k8s_host" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
}

output "k8s_ca_certificate" {
  value = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
}

output "k8s_client_certificate" {
  value = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
}

output "k8s_client_key" {
  value = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
}
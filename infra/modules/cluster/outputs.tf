output "kubernetes_client_configuration" {
  sensitive = true
  value     = talos_cluster_kubeconfig.this.kubernetes_client_configuration
}
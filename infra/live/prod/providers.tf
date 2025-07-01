terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "6.6.0"
    }
  }
}

provider "kubernetes" {
  alias = "configured"
  host = module.cluster.k8s_host
  client_certificate = module.cluster.k8s_client_certificate
  client_key = module.cluster.k8s_client_key
  cluster_ca_certificate = module.cluster.k8s_ca_certificate
}

provider "helm" {
  alias = "configured"
  kubernetes = {
    host = module.cluster.k8s_host
    client_certificate = module.cluster.k8s_client_certificate
    client_key = module.cluster.k8s_client_key
    cluster_ca_certificate = module.cluster.k8s_ca_certificate
  }
}

provider "github" {
  owner = var.github_organization
}
# Resources
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "git_auth" {
  count      =  var.git_token != "" || var.github_app_id != "" ? 1 : 0
  depends_on = [kubernetes_namespace.flux_system]

  metadata {
    name      = "flux-system"
    namespace = "flux-system"
  }

  data = {
    username = var.git_token != "" ? "git" : null
    password = var.git_token != "" ? var.git_token : null
    githubAppID = var.github_app_id != "" ? var.github_app_id : null
    githubAppInstallationID = var.github_app_installation_id != "" ? var.github_app_installation_id : null
    githubAppPrivateKey = var.github_app_pem != "" ? var.github_app_pem: null
  }

  type = "Opaque"
}

resource "helm_release" "flux_instance" {
  depends_on = [helm_release.flux_operator]

  name       = "flux"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"

  // Configure the Flux components and kustomize patches.
  values = [
    file("values/components.yaml")
  ]

  // Configure the Flux distribution.
  set {
    name  = "instance.distribution.version"
    value = var.flux_version
  }
  set {
    name  = "instance.distribution.registry"
    value = var.flux_registry
  }

  // Configure Flux Git sync.
  set {
    name  = "instance.sync.kind"
    value = "GitRepository"
  }
  set {
    name  = "instance.sync.url"
    value = var.git_url
  }
  set {
    name  = "instance.sync.path"
    value = var.git_path
  }
  set {
    name  = "instance.sync.ref"
    value = var.git_ref
  }
  set {
    name  = "instance.sync.provider"
    value = var.github_app_id != "" ? "github" : "generic"
  }
  set {
    name  = "instance.sync.pullSecret"
    value = var.git_token != "" || var.github_app_id != "" ? "flux-system" : ""
  }
}
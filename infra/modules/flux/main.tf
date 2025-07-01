# Resources
resource "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  lifecycle {
    ignore_changes = [metadata]
  }
}

resource "kubernetes_secret" "git_ssh_auth" {
  depends_on = [kubernetes_namespace.flux_system]

  metadata {
    name      = "git-ssh-auth"
    namespace = "flux-system"
  }

  data = {
    "identity.pub" = var.git_public_key
    "identity" = var.git_private_key
    "known_hosts"  = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
  }

  type = "Opaque"
}

resource "helm_release" "flux_operator" {
  depends_on = [kubernetes_namespace.flux_system]

  name       = "flux-operator"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-operator"
  wait       = true
}

resource "helm_release" "flux_instance" {
  depends_on = [kubernetes_secret.git_ssh_auth, helm_release.flux_operator]

  name       = "flux"
  namespace  = "flux-system"
  repository = "oci://ghcr.io/controlplaneio-fluxcd/charts"
  chart      = "flux-instance"

  // Configure the Flux components and kustomize patches.
  values = [file("${path.module}/values/components.yaml")]

  set = [
    // Configure the Flux distribution.
    {name  = "instance.distribution.version", value = var.flux_version},
    {name  = "instance.distribution.registry", value = var.flux_registry},

    // Configure Flux Git sync.
    {name  = "instance.sync.kind", value = "GitRepository"},
    {name  = "instance.sync.url", value = var.git_url},
    {name  = "instance.sync.path", value = var.git_path},
    {name  = "instance.sync.ref", value = var.git_ref},
    {name  = "instance.sync.pullSecret", value = kubernetes_secret.git_ssh_auth.metadata.0.name}
  ]

  provisioner "local-exec" {
    when = destroy
    command = "kubectl -n flux-system delete fluxinstances --all"
  }
}
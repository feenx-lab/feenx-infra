# Resource
resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "flux_deploy_key" {
  title = "FluxCD Deploy Key"
  repository = var.repo_name
  key = tls_private_key.this.public_key_openssh
  read_only = false

  lifecycle {
    replace_triggered_by = [
      tls_private_key.this
    ]
  }
}
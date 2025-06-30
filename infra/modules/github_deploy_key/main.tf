# Data
data "github_repository" "this" {
  full_name = var.full_repo_name
}

# Resource
resource "tls_private_key" "this" {
  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "flux_deploy_key" {
  title = "FluxCD Deploy Key"
  repository = data.github_repository.this.name
  key = tls_private_key.this.public_key_openssh
  read_only = false

  lifecycle {
    ignore_changes = [
      repository
    ]
    replace_triggered_by = [
      tls_private_key.this
    ]
  }
}
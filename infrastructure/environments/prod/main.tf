variable "namespace" {
  default = "prod"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

data "sops_file" "database" {
  source_file = "../../charts/database/values-secrets-prod.yaml"
}

module "app" {
  source = "../../shared"

  namespace = var.namespace

  frontend_values = [
    file("../../charts/frontend/values.yaml"),
    file("../../charts/frontend/values-prod.yaml")
  ]

  backend_values = [
    file("../../charts/backend/values.yaml"),
    file("../../charts/backend/values-prod.yaml")
  ]

  database_values_file = "../../charts/database/values.yaml"
  database_secrets     = data.sops_file.database
}

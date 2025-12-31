variable "namespace" {
  default = "dev"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "frontend" {
  name      = "frontend"
  chart     = "../../charts/frontend"
  namespace = var.namespace
  values = [
    file("../../charts/frontend/values.yaml"),
    file("../../charts/frontend/values-dev.yaml")
  ]
}

resource "helm_release" "backend" {
  name      = "backend"
  chart     = "../../charts/backend"
  namespace = var.namespace
  values = [
    file("../../charts/backend/values.yaml"),
    file("../../charts/backend/values-dev.yaml")
  ]
}

# SOPS secrets directly in root module
data "sops_file" "database" {
  source_file = "../../charts/database/values-secrets-dev.yaml"
}

resource "helm_release" "database" {
  name      = "database"
  chart     = "../../charts/database"
  namespace = var.namespace
  values    = [file("../../charts/database/values.yaml")]

  set {
    name  = "postgres.username"
    value = data.sops_file.database.data["postgres.username"]
  }

  set {
    name  = "postgres.password"
    value = data.sops_file.database.data["postgres.password"]
  }

  set {
    name  = "postgres.db"
    value = data.sops_file.database.data["postgres.db"]
  }
}

# TODO: is the above approach fine or should we make it better reusable? not sure...

# module "app" {
#   source = "../../modules/app"
#   namespace = var.namespace
#
#   frontend_values = [
#     file("../../charts/frontend/values.yaml"),
#     file("../../charts/frontend/values-dev.yaml")
#   ]
#
#   backend_values = [
#     file("../../charts/backend/values.yaml"),
#     file("../../charts/backend/values-dev.yaml")
#   ]
#
#   database_value   = [file("../../charts/database/values.yaml")]
#   database_secrets = data.sops_file.database
# }

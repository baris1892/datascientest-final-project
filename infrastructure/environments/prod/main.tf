variable "namespace" {
  default = "prod"
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
    file("../../charts/frontend/values-prod.yaml")
  ]
}

resource "helm_release" "backend" {
  name      = "backend"
  chart     = "../../charts/backend"
  namespace = var.namespace
  values = [
    file("../../charts/backend/values.yaml"),
    file("../../charts/backend/values-prod.yaml")
  ]
}

data "sops_file" "database_secrets" {
  source_file = "../../charts/database/values-secrets-prod.yaml"
}

resource "helm_release" "database" {
  name      = "database"
  chart     = "../../charts/database"
  namespace = var.namespace
  values    = [file("../../charts/database/values.yaml")]

  set {
    name  = "postgres.username"
    value = data.sops_file.database_secrets.data["postgres.username"]
  }

  set {
    name  = "postgres.password"
    value = data.sops_file.database_secrets.data["postgres.password"]
  }

  set {
    name  = "postgres.db"
    value = data.sops_file.database_secrets.data["postgres.db"]
  }
}

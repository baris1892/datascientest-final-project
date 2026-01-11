variable "namespace" {
  default = "dev"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = var.namespace
  }
}

data "sops_file" "database_secrets" {
  source_file = "../../charts/database/values-secrets-dev.yaml"
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

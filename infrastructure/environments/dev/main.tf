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

resource "helm_release" "postgres_exporter" {
  name       = "postgres-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-postgres-exporter"
  namespace  = var.namespace

  set {
    name  = "config.datasource.host"
    value = "database-db" # Service-Name of DB Helm Charts
  }

  set {
    name  = "config.datasource.user"
    value = data.sops_file.database_secrets.data["postgres.username"]
  }

  # Fixed connection database to ensure the exporter can always log in,
  # regardless of whether the username matches the application database name.
  set {
    name  = "config.datasource.database"
    value = "postgres"
  }

  set {
    name  = "config.datasource.password"
    value = data.sops_file.database_secrets.data["postgres.password"]
  }

  # "Magic Part": Enables the Prometheus Operator to automatically discover this exporter across namespaces
  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "serviceMonitor.namespace"
    value = var.namespace
  }
}

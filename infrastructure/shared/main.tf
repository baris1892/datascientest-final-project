resource "helm_release" "frontend" {
  name      = "frontend"
  chart     = "${path.module}/../charts/frontend"
  namespace = var.namespace
  values    = var.frontend_values
}

resource "helm_release" "backend" {
  name      = "backend"
  chart     = "${path.module}/../charts/backend"
  namespace = var.namespace
  values    = var.backend_values
}

resource "helm_release" "database" {
  name      = "database"
  chart     = "${path.module}/../charts/database"
  namespace = var.namespace
  values    = [file(var.database_values_file)]

  set {
    name  = "postgres.username"
    value = var.database_secrets.data["postgres.username"]
  }

  set {
    name  = "postgres.password"
    value = var.database_secrets.data["postgres.password"]
  }

  set {
    name  = "postgres.db"
    value = var.database_secrets.data["postgres.db"]
  }
}

resource "helm_release" "mailpit" {
  name       = "mailpit"
  repository = "https://jouve.github.io/charts"
  chart      = "mailpit"
  version    = "0.31.0"
  namespace = var.monitoring_namespace

  values = [
    file("${path.module}/mailpit-values.yaml")
  ]
}

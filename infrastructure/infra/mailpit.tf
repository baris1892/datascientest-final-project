resource "helm_release" "mailpit" {
  name       = "mailpit"
  repository = "https://jouve.github.io/charts"
  chart      = "mailpit"
  version    = "0.31.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  values = [
    file("${path.module}/mailpit-values.yaml")
  ]
}

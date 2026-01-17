resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "helm_release" "prometheus_stack" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "81.0.0"

  # Hier binden wir die externe Konfigurationsdatei ein
  values = [
    file("${path.module}/kube-prometheus-stack-values.yaml")
  ]
}

resource "kubernetes_config_map" "traefik_custom_dashboard" {
  metadata {
    name      = "traefik-custom-dashboard"
    namespace  = kubernetes_namespace.monitoring.metadata[0].name

    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "traefik-dashboard.json" = file("${path.module}/dashboards/traefik_custom_dashboard.json")
  }
}

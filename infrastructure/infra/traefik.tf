resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "ingress-system"
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  version    = "38.0.2"

  values = [yamlencode({
    service = {
      type = "LoadBalancer"
    }
    ports = {
      web = {
        redirections = {
          entryPoint = {
            to     = "websecure"
            scheme = "https"
          }
        }
      }
    }
    ingressClass = {
      enabled        = true
      isDefaultClass = true
      name           = "traefik"
    }
    metrics = {
      prometheus = {
        enabled = true
        # Essential for per-app metrics (Namespace/Service)
        addRoutersLabels  = true
        addServicesLabels = true
        serviceMonitor = {
          enabled = true
          # Crucial: This label allows the Prometheus Operator to discover Traefik
          additionalLabels = {
            release = "prometheus"
          }
        }
      }
    }
  })]
}

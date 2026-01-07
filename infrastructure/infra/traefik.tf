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
  })]
}

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
    namespace = kubernetes_namespace.monitoring.metadata[0].name

    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "traefik-dashboard.json" = file("${path.module}/dashboards/traefik_custom_dashboard.json")
  }
}

resource "helm_release" "blackbox_exporter" {
  name       = "blackbox-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Override the long name to something simpler
  set {
    name  = "fullnameOverride"
    value = "blackbox-exporter"
  }

  values = [
    yamlencode({
      config = {
        modules = {
          http_2xx = {
            prober = "http"
            http = {
              # We remove valid_status_codes because the default is already 2xx.
              preferred_ip_protocol = "ip4"
            }
          }
        }
      }
    })
  ]
}

resource "kubernetes_manifest" "backend_probes" {
  # This creates one Probe for each environment (dev and prod)
  for_each = toset(["dev", "prod"])

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "Probe"
    metadata = {
      name      = "backend-health-${each.key}"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels = {
        release = "prometheus" # Matches Helm release name
      }
    }
    spec = {
      jobName = "backend-health-${each.key}"
      prober = {
        # Internal DNS of the blackbox exporter
        url = "blackbox-exporter.monitoring.svc.cluster.local:9115"
      }
      module = "http_2xx"
      targets = {
        staticConfig = {
          static = [
            # Dynamic DNS based on the namespace (dev/prod)
            "http://backend.${each.key}.svc.cluster.local:9966/petclinic/actuator/health"
          ]
          # Labels to distinguish them in Grafana
          labels = {
            env = each.key
            app = "petclinic-backend"
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "frontend_probes" {
  for_each = toset(["dev", "prod"])

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "Probe"
    metadata = {
      name      = "frontend-health-${each.key}"
      namespace = kubernetes_namespace.monitoring.metadata[0].name
      labels    = { release = "prometheus" }
    }
    spec = {
      jobName = "frontend-health-${each.key}"
      prober = {
        url = "blackbox-exporter.monitoring.svc.cluster.local:9115"
      }
      module = "http_2xx"
      targets = {
        staticConfig = {
          static = ["http://frontend.${each.key}.svc.cluster.local:80/"]
          labels = {
            env = each.key
            app = "petclinic-frontend"
          }
        }
      }
    }
  }
}

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = "6.50.0"

  values = [
    yamlencode({
      deploymentMode = "SingleBinary"

      loki = {
        auth_enabled = false

        commonConfig = {
          replication_factor = 1
        }

        schemaConfig = {
          configs = [{
            from         = "2024-04-01"
            store        = "tsdb"
            object_store = "filesystem"
            schema       = "v13"
            index = {
              prefix = "loki_index_"
              period = "24h"
            }
          }]
        }

        storage = {
          type = "filesystem"
        }
      }

      singleBinary = {
        replicas = 1
        persistence = {
          enabled = true
          size    = "1Gi"
        }
      }

      # Disable all microservices
      backend = { replicas = 0 }
      read    = { replicas = 0 }
      write   = { replicas = 0 }

      gateway = {
        enabled = true
      }

      test = {
        enabled = false
      }
    })
  ]
}

# note: we might need to adjust: /etc/sysctl.conf
# and add the following to get rid of "too many open files":
# fs.inotify.max_user_instances = 1024
# fs.inotify.max_user_watches = 524288
resource "helm_release" "alloy" {
  name       = "alloy"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = "1.6.0"
  values = [
    file("${path.module}/alloy-values.yaml")
  ]
  depends_on = [helm_release.loki]
}

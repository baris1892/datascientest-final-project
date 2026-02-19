output "monitoring_namespace_name" {
  value = kubernetes_namespace.monitoring.metadata[0].name
}

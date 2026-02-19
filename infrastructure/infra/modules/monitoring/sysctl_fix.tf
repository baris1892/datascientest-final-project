# this fixes error "failed to create fsnotify watcher: too many open files"
resource "kubernetes_daemonset" "sysctl_fix" {
  metadata {
    name      = "sysctl-fix"
    namespace = "kube-system"
  }
  spec {
    selector {
      match_labels = {
        name = "sysctl-fix"
      }
    }
    template {
      metadata {
        labels = {
          name = "sysctl-fix"
        }
      }
      spec {
        host_pid = true
        container {
          name    = "sysctl-fix"
          image   = "busybox"
          command = ["sh", "-c", "sysctl -w fs.inotify.max_user_instances=1024 && sysctl -w fs.inotify.max_user_watches=524288 && sleep infinity"]
          security_context {
            privileged = true
          }
        }
      }
    }
  }
}

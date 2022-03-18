resource "kubernetes_config_map_v1" "app_kubecfg" {
  metadata {
    name = "app-kubecfg"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.vsite}"
    }
  }
  data = {
    kubeconfig = base64decode(var.app_kubecfg)
  }
}

resource "kubernetes_cron_job" "podcleaner" {
  depends_on = [kubernetes_secret_v1.registry-secret]
  metadata {
    name = "podcleaner"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.vsite}"
    }
  }
  spec {
    schedule = "* * * * *"
    job_template {
      metadata {}
      spec {
        template {
          metadata {
            annotations = {
              "ves.io/virtual-sites" = "${var.namespace}/${var.vsite}"
              "ves.io/workload-flavor" = "tiny"
            }
          }
          spec {
            volume {
              name = "kubecfg"
              config_map {
                name = "app-kubecfg"
                items {
                  key  = "kubeconfig"
                  path = "kubeconfig"
                }
              }
            }
            container {
              name  = "cleaner"
              image = "${var.registry_server}/cleaner"
              env {
                name  = "NAMESPACE"
                value = "${var.app_namespace}"
              }
              env {
                name  = "KUBE_PATH"
                value = "/tmp/kubeconfig"
              }
              volume_mount {
                name       = "kubecfg"
                read_only  = true
                mount_path = "/tmp"
              }
              termination_message_path   = "/dev/termination-log"
              termination_message_policy = "File"
              image_pull_policy          = "Always"
            }
            restart_policy                   = "OnFailure"
            termination_grace_period_seconds = 30
            dns_policy                       = "ClusterFirst"
            image_pull_secrets {
              name = "f5demos-registry-secret"
            }
          }
        }
      }
    }
    failed_jobs_history_limit = 10
  }
}


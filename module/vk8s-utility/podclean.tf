resource "kubernetes_config_map" "app_kubecfg" {
  metadata {
    name = "app-kubecfg"
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.vsite}"
    }
  }
  data = {
    kubeconfig = "${var.app_kubecfg}"
  }
}

resource "kubernetes_cron_job" "podcleaner" {
  metadata {
    name = "podcleaner"
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.vsite}"
    }
  }
  spec {
    schedule = "*/6 * * * *"
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
              image = "${var.reg_server}/cleaner"
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
    failed_jobs_history_limit = 1
  }
}

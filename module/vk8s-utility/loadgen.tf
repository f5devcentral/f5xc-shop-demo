resource "kubernetes_cron_job" "shop_traffic_gen" {
  depends_on = [kubernetes_secret.registry-secret]
  metadata {
    name = "shop-traffic-gen"
    namespace = var.namespace
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
            container {
              name  = "shop-traffic-gen"
              image = "${var.registry_server}/loadgen"
              env {
                name  = "DURATION"
                value = "5m"
              }
              env {
                name  = "TARGET_URL"
                value = "${var.target_url}"
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


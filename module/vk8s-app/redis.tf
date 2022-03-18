resource "kubernetes_deployment" "redis_cart" {
  metadata {
    name = "redis-cart"
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.hub_vsite}"
      "ves.io/workload-flavor" = "ves-io-medium"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "redis-cart"
      }
    }
    template {
      metadata {
        labels = {
          app = "redis-cart"
        }
      }
      spec {
        volume {
          name      = "redis-data"
          empty_dir = {}
        }
        container {
          name  = "redis"
          image = "${var.reg_server}/redis:alpine"
          port {
            container_port = 6379
          }
          volume_mount {
            name       = "redis-data"
            mount_path = "/data"
          }
          liveness_probe {
            tcp_socket {
              port = "6379"
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
          readiness_probe {
            tcp_socket {
              port = "6379"
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
        image_pull_secrets {
          name = "f5demos-registry-secret"
        }
      }
    }
  }
}

resource "kubernetes_service" "redis_cart" {
  metadata {
    name = "redis-cart"
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.hub_vsite}"
    }
  }
  spec {
    port {
      name        = "redis"
      port        = 6379
      target_port = "6379"
    }
    selector = {
      app = "redis-cart"
    }
    type = "ClusterIP"
  }
}
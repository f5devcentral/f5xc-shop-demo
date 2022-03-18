resource "kubernetes_deployment" "cartservice" {
  metadata {
    name = "cartservice"
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-medium"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "cartservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "cartservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/cartservice:v0.3.6"
          port {
            container_port = 7070
          }
          env {
            name  = "REDIS_ADDR"
            value = "redis-cart.internal:6379"
          }
          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7070", "-rpc-timeout=5s"]
            }
            initial_delay_seconds = 20
            timeout_seconds       = 2
            period_seconds        = 10
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7070", "-rpc-timeout=5s"]
            }
            initial_delay_seconds = 10
            timeout_seconds       = 2
          }
        }
        termination_grace_period_seconds = 5
        service_account_name             = "default"
      }
    }
  }
}

resource "kubernetes_service" "cartservice" {
  metadata {
    name = "cartservice"
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "${var.namepace}/${var.spoke_vsite}"
    }
  }
  spec {
    port {
      name        = "grpc"
      port        = 7070
      target_port = "7070"
    }
    selector = {
      app = "cartservice"
    }
    type = "ClusterIP"
  }
}
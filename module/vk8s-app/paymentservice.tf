resource "kubernetes_deployment" "paymentservice" {
  metadata {
    name = "paymentservice"
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-tiny"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "paymentservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "paymentservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/paymentservice:v0.3.6"
          port {
            container_port = 50051
          }
          env {
            name  = "PORT"
            value = "50051"
          }
          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }
          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }
          env {
            name  = "DISABLE_DEBUGGER"
            value = "1"
          }
          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }
            initial_delay_seconds = 10
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }
            initial_delay_seconds = 5
          }
        }
        termination_grace_period_seconds = 5
        service_account_name             = "default"
      }
    }
  }
}

resource "kubernetes_service" "paymentservice" {
  metadata {
    name = "paymentservice"
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
    }
  }
  spec {
    port {
      name        = "grpc"
      port        = 50051
      target_port = "50051"
    }
    selector = {
      app = "paymentservice"
    }
    type = "ClusterIP"
  }
}
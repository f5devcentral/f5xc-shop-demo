resource "kubernetes_deployment" "currencyservice" {
  metadata {
    name = "currencyservice"
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-tiny"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "currencyservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "currencyservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/currencyservice:v0.3.6"
          port {
            name           = "grpc"
            container_port = 7000
          }
          env {
            name  = "PORT"
            value = "7000"
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
              command = ["/bin/grpc_health_probe", "-addr=:7000"]
            }
            initial_delay_seconds = 10
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:7000"]
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

resource "kubernetes_service" "currencyservice" {
  metadata {
    name = "currencyservice"
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
    }
  }
  spec {
    port {
      name        = "grpc"
      port        = 7000
      target_port = "7000"
    }
    selector = {
      app = "currencyservice"
    }
    type = "ClusterIP"
  }
}
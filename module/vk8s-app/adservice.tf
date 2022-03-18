resource "kubernetes_deployment" "adservice" {
  metadata {
    name = "adservice"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.hub_vsite}"
      "ves.io/workload-flavor" = "ves-io-medium"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "adservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "adservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/adservice:v0.3.6"
          port {
            container_port = 9555
          }
          env {
            name  = "PORT"
            value = "9555"
          }
          env {
            name  = "DISABLE_STATS"
            value = "1"
          }
          env {
            name  = "DISABLE_TRACING"
            value = "1"
          }
          env {
            name  = "DISABLE_PROFILER"
            value = "1"
          }
          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:9555"]
            }
            initial_delay_seconds = 20
            period_seconds        = 15
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:9555"]
            }
            initial_delay_seconds = 20
            period_seconds        = 15
          }
        }
        termination_grace_period_seconds = 5
        service_account_name             = "default"
      }
    }
  }
}

resource "kubernetes_service" "adservice" {
  metadata {
    name = "adservice"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.hub_vsite}"
    }
  }
  spec {
    port {
      name        = "grpc"
      port        = 9555
      target_port = "9555"
    }
    selector = {
      app = "adservice"
    }
    type = "ClusterIP"
  }
}
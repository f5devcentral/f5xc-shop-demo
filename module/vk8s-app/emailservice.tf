resource "kubernetes_deployment_v1" "emailservice" {
  metadata {
    name = "emailservice"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-tiny"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "emailservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "emailservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/emailservice:v0.3.6"
          port {
            container_port = 8080
          }
          env {
            name  = "PORT"
            value = "8080"
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
            name  = "DISABLE_PROFILER"
            value = "1"
          }
          liveness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }
            initial_delay_seconds = 10
            timeout_seconds       = 2
            period_seconds        = 5
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }
            initial_delay_seconds = 5
            timeout_seconds       = 2
            period_seconds        = 5
          }
        }
        termination_grace_period_seconds = 5
        service_account_name             = "default"
      }
    }
  }
}

resource "kubernetes_service_v1" "emailservice" {
  metadata {
    name = "emailservice"
    namespace = var.namespace
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
    }
  }
  spec {
    port {
      name        = "grpc"
      port        = 5000
      target_port = "8080"
    }
    selector = {
      app = "emailservice"
    }
    type = "ClusterIP"
  }
}
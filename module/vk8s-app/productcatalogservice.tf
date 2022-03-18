resource "kubernetes_deployment" "productcatalogservice" {
  metadata {
    name = "productcatalogservice"
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-tiny"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "productcatalogservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "productcatalogservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/productcatalogservice:v0.3.6"
          port {
            container_port = 3550
          }
          env {
            name  = "PORT"
            value = "3550"
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
              command = ["/bin/grpc_health_probe", "-addr=:3550"]
            }
            initial_delay_seconds = 10
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:3550"]
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

resource "kubernetes_service" "productcatalogservice" {
  metadata {
    name = "productcatalogservice"
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
    }
  }
  spec {
    port {
      name        = "grpc"
      port        = 3550
      target_port = "3550"
    }
    selector = {
      app = "productcatalogservice"
    }
    type = "ClusterIP"
  }
}
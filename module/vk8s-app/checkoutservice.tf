resource "kubernetes_deployment" "checkoutservice" {
  metadata {
    name = "checkoutservice"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-tiny"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "checkoutservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "checkoutservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/checkoutservice:v0.3.6"
          port {
            container_port = 5050
          }
          env {
            name  = "PORT"
            value = "5050"
          }
          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice:3550"
          }
          env {
            name  = "SHIPPING_SERVICE_ADDR"
            value = "shippingservice:50051"
          }
          env {
            name  = "PAYMENT_SERVICE_ADDR"
            value = "paymentservice:50051"
          }
          env {
            name  = "EMAIL_SERVICE_ADDR"
            value = "emailservice:5000"
          }
          env {
            name  = "CURRENCY_SERVICE_ADDR"
            value = "currencyservice:7000"
          }
          env {
            name  = "CART_SERVICE_ADDR"
            value = "cartservice:7070"
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
              command = ["/bin/grpc_health_probe", "-addr=:5050"]
            }
            initial_delay_seconds = 10
            timeout_seconds       = 2
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:5050"]
            }
            initial_delay_seconds = 5
            timeout_seconds       = 2
          }
        }
        service_account_name = "default"
      }
    }
  }
}

resource "kubernetes_service" "checkoutservice" {
  metadata {
    name = "checkoutservice"
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
      port        = 5050
      target_port = "5050"
    }
    selector = {
      app = "checkoutservice"
    }
    type = "ClusterIP"
  }
}
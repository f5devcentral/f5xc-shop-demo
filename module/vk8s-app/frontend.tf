resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-tiny"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        volume {
          name = "nginx-conf"
          config_map {
            name = "nginx-conf"
            items {
              key  = "default.conf"
              path = "default.conf"
            }
          }
        }
        volume {
          name = "error-html"
          config_map {
            name = "error-html"
            items {
              key  = "error.html"
              path = "error.html"
            }
          }
        }
        container {
          name  = "frontend"
          image = "gcr.io/google-samples/microservices-demo/frontend:v0.3.6"
          port {
            container_port = 8080
          }
          env {
            name  = "PORT"
            value = "8080"
          }
          env {
            name  = "PRODUCT_CATALOG_SERVICE_ADDR"
            value = "productcatalogservice:3550"
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
            name  = "RECOMMENDATION_SERVICE_ADDR"
            value = "recommendationservice:8080"
          }
          env {
            name  = "SHIPPING_SERVICE_ADDR"
            value = "shippingservice:50051"
          }
          env {
            name  = "CHECKOUT_SERVICE_ADDR"
            value = "checkoutservice:5050"
          }
          env {
            name  = "AD_SERVICE_ADDR"
            value = "adservice.internal:9555"
          }
          env {
            name  = "ENV_PLATFORM"
            value = "local"
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
            http_get {
              path = "/_healthz"
              port = "8080"
              http_header {
                name  = "Cookie"
                value = "shop_session-id=x-liveness-probe"
              }
            }
            initial_delay_seconds = 20
          }
          readiness_probe {
            http_get {
              path = "/_healthz"
              port = "8080"
              http_header {
                name  = "Cookie"
                value = "shop_session-id=x-readiness-probe"
              }
            }
            initial_delay_seconds = 10
          }
        }
        container {
          name  = "proxy"
          image = "${var.registry_server}/proxy"
          port {
            container_port = 8181
          }
          volume_mount {
            name       = "nginx-conf"
            read_only  = true
            mount_path = "/etc/nginx/conf.d"
          }
          volume_mount {
            name       = "error-html"
            read_only  = true
            mount_path = "/usr/share/nginx/html"
          }
          liveness_probe {
            http_get {
              path = "/_healthy"
              port = "8181"
            }
            initial_delay_seconds = 10
          }
          readiness_probe {
            http_get {
              path = "/_healthy"
              port = "8181"
            }
            initial_delay_seconds = 5
          }
        }
        service_account_name = "default"
        image_pull_secrets {
          name = "f5demos-registry-secret"
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
    }
  }
  spec {
    port {
      name        = "http"
      port        = 80
      target_port = "8181"
    }
    selector = {
      app = "frontend"
    }
    type = "ClusterIP"
  }
}
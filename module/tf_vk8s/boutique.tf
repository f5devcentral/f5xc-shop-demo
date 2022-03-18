resource "kubernetes_deployment" "emailservice" {
  metadata {
    name = "emailservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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

resource "kubernetes_service" "emailservice" {
  metadata {
    name = "emailservice"
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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

resource "kubernetes_deployment" "adservice" {
  metadata {
    name = "adservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${hub_vsite}"
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
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${hub_vsite}"
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

resource "kubernetes_deployment" "checkoutservice" {
  metadata {
    name = "checkoutservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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

resource "kubernetes_deployment" "recommendationservice" {
  metadata {
    name = "recommendationservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-tiny"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "recommendationservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "recommendationservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/recommendationservice:v0.3.6"
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
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }
            initial_delay_seconds = 10
            period_seconds        = 5
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:8080"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
        termination_grace_period_seconds = 5
        service_account_name             = "default"
      }
    }
  }
}

resource "kubernetes_service" "recommendationservice" {
  metadata {
    name = "recommendationservice"
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
    }
  }
  spec {
    port {
      name        = "grpc"
      port        = 8080
      target_port = "8080"
    }
    selector = {
      app = "recommendationservice"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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
          image = "$${reg_server}/proxy"
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
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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

resource "kubernetes_deployment" "paymentservice" {
  metadata {
    name = "paymentservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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

resource "kubernetes_deployment" "productcatalogservice" {
  metadata {
    name = "productcatalogservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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

resource "kubernetes_deployment" "cartservice" {
  metadata {
    name = "cartservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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
      "ves.io/virtual-sites" = "$${namepace}/$${spoke_vsite}"
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

resource "kubernetes_deployment" "currencyservice" {
  metadata {
    name = "currencyservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
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

resource "kubernetes_deployment" "shippingservice" {
  metadata {
    name = "shippingservice"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
      "ves.io/workload-flavor" = "ves-io-tiny"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "shippingservice"
      }
    }
    template {
      metadata {
        labels = {
          app = "shippingservice"
        }
      }
      spec {
        container {
          name  = "server"
          image = "gcr.io/google-samples/microservices-demo/shippingservice:v0.3.6"
          port {
            container_port = 50051
          }
          env {
            name  = "PORT"
            value = "50051"
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
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }
            initial_delay_seconds = 10
          }
          readiness_probe {
            exec {
              command = ["/bin/grpc_health_probe", "-addr=:50051"]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }
        }
        service_account_name = "default"
      }
    }
  }
}

resource "kubernetes_service" "shippingservice" {
  metadata {
    name = "shippingservice"
    annotations = {
      "ves.io/http2-enable" = "true"
      "ves.io/proxy-type" = "HTTP_PROXY"
      "ves.io/virtual-sites" = "$${namespace}/$${spoke_vsite}"
    }
  }
  spec {
    port {
      name        = "grpc"
      port        = 50051
      target_port = "50051"
    }
    selector = {
      app = "shippingservice"
    }
    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "redis_cart" {
  metadata {
    name = "redis-cart"
    annotations = {
      "ves.io/virtual-sites" = "$${namespace}/$${hub_vsite}"
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
          image = "$${reg_server}/redis:alpine"
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
      "ves.io/virtual-sites" = "$${namespace}/$${hub_vsite}"
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


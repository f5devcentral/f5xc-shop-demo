data "template_file" "nginx_conf" {
  template = "${file("${path.module}/../../misc/nginx_conf.tpl")}"
  vars = {
    tenant_js_ref  = var.tenant_js_ref
  }
}

resource "kubernetes_config_map" "nginx_conf" {
  metadata {
    name = "nginx-conf"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
    }
  }
  data = {
    "default.conf" = data.template_file.nginx_conf.rendered
  }
}

resource "kubernetes_config_map" "error_html" {
  metadata {
    name = "error-html"
    namespace = var.namespace
    annotations = {
      "ves.io/virtual-sites" = "${var.namespace}/${var.spoke_vsite}"
    }
  }
  data = {
    "error.html" = file("${path.module}/../../misc/error.html")
  }
}


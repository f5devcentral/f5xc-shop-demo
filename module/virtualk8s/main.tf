terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
      configuration_aliases = [kubectl.app, kubectl.utility]
    }   
    local = {
      source = "hashicorp/local"
      version = "2.2.2"
    } 
  }
}

data "kubectl_path_documents" "app-manifests" {
    provider = kubectl.app
    pattern  = "${path.module}/app-manifests/*.yaml"
    vars = {
        namespace = var.app_namespace,
        spoke_vsite = var.spoke_vsite,
        hub_vsite = var.hub_vsite,
        reg_server = var.reg_server,
        registry_config_json = var.registry_config_json,
        reg_server = var.reg_server,
        tenant_js_ref = var.tenant_js_ref
    }
}

data "kubectl_path_documents" "utility-manifests" {
    provider =  kubectl.utility
    pattern  = "${path.module}/utility-manifests/*.yaml"
    vars = {
        utility_namespace = var.utility_namespace,
        utility_vsite = var.utility_vsite,
        reg_server = var.reg_server,
        registry_config_json = var.registry_config_json,
        target_url = var.target_url,
        app_namespace = var.app_namespace
        app_kubecfg = base64decode(var.app_kubecfg.content)
    }
}

resource "kubectl_manifest" "app-resources" {
    provider  = kubectl.app
    for_each  = toset(data.kubectl_path_documents.app-manifests.documents)
    yaml_body = each.value
    override_namespace = var.app_namespace
}

resource "kubectl_manifest" "utility-resources" {
    provider  = kubectl.utility
    for_each  = toset(data.kubectl_path_documents.utility-manifests.documents)
    yaml_body = each.value
    override_namespace = var.utility_namespace
}

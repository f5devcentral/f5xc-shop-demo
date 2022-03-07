provider "kubectl" {
    alias = "app"
}

provider "kubectl" {
    alias = "utility"
}

data "app_documents" "manifests" {
    pattern = "${path.module}/app-manifests/*.yaml"
    vars = {
        namespace = var.namespace,
        spoke_vsite = var.spoke_vsite,
        hub_vsite = var.hub_vsite,
        reg_password_b64 = var.reg_password_b64,
        reg_server_b64 = var.reg_server_b64,
        reg_username_b64 = var.reg_username_b64,
        reg_server = var.reg_server
        tenant_js_ref = var.tenant_js_ref
    }
}

data "utility_documents" "manifests" {
    pattern = "${path.module}/utility-manifests/*.yaml"
    vars = {
        utility_namespace = var.utility_namespace,
        utility_vsite = var.utility_vsite,
        reg_password_b64 = var.reg_password_b64,
        reg_server_b64 = var.reg_server_b64,
        reg_username_b64 = var.reg_username_b64,
        reg_server = var.reg_server
        target_url = var.target_url
    }
}
resource "kubectl_manifest" "manifests" {
    provider  = kubectl.app
    count     = length(data.app_documents.manifests.documents)
    yaml_body = element(data.app_documents.manifests.documents, count.index)
    override_namespace = var.namespace
}

resource "kubectl_manifest" "manifests" {
    provider  = kubectl.utility
    count     = length(data.utility_documents.manifests.documents)
    yaml_body = element(data.utiltity_documents.manifests.documents, count.index)
    override_namespace = var.utility_namespace
}
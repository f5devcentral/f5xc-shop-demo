data "utility_documents" "manifests" {
    pattern = "${path.module}/manifests/*.yaml"
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
    count     = length(data.utility_documents.manifests.documents)
    yaml_body = element(data.utiltity_documents.manifests.documents, count.index)
    override_namespace = var.utility_namespace
}
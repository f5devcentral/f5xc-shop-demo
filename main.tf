terraform {
  required_version = ">= 0.15"
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
      version = "0.11.3"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "volterra" {
  api_p12_file = "${path.root}/creds/${var.api_p12_file}"
  url          = var.api_url
}

provider "kubectl" {
  alias                  = "app"
  host                   = module.f5xc.app_kubecfg_host
  cluster_ca_certificate = base64decode(module.f5xc.app_kubecfg_cluster_ca)
  client_certificate     = base64decode(module.f5xc.app_kubecfg_client_cert)
  client_key             = base64decode(module.f5xc.app_kubecfg_client_key)
  load_config_file       = false
  apply_retry_count      = 10
}

provider "kubectl" {
  alias                  = "utility"
  host                   = module.f5xc.utility_kubecfg_host
  cluster_ca_certificate = base64decode(module.f5xc.utility_kubecfg_cluster_ca)
  client_certificate     = base64decode(module.f5xc.utility_kubecfg_client_cert)
  client_key             = base64decode(module.f5xc.utility_kubecfg_client_key)
  load_config_file       = false
  apply_retry_count      = 10
}

module "f5xc" {
  source = "./module/f5xc"

  api_url = var.api_url
  api_p12_file = "${path.module}/../../creds/${var.api_p12_file}"
  base = var.base
  app_fqdn = var.app_fqdn
  spoke_site_selector = var.spoke_site_selector
  hub_site_selector = var.hub_site_selector
  utility_site_selector = var.utility_site_selector
  cred_expiry_days = var.cred_expiry_days
  bot_defense_region = var.bot_defense_region
}
 
module "virtualk8s" {
  source = "./module/virtualk8s"
  providers = {
    kubectl.app     = kubectl.app
    kubectl.utility = kubectl.utility
  }
  
  reg_server = var.registry_server
  registry_config_json = var.registry_config_json

  app_namespace = module.f5xc.app_namespace
  utility_namespace = module.f5xc.utility_namespace
  spoke_vsite = module.f5xc.spoke_vsite
  hub_vsite = module.f5xc.hub_vsite
  utility_vsite = module.f5xc.utility_vsite
  target_url = module.f5xc.app_url
  app_kubecfg = module.f5xc.app_kubecfg

  tenant_js_ref = var.tenant_js_ref
}
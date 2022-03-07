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
  api_p12_file = "./cred.p12"
  url          = var.api_url
}

provider "kubectl" {
  alias = "app"
  config_path = module.f5xc.app_kubecfg
  apply_retry_count = 2
}

provider "kubectl" {
  alias = "utility"
  config_path = module.f5xc.utility_kubecfg
  apply_retry_count = 2
}

module "f5xc" {
  source = "./module/f5xc"

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
  reg_password_b64 = base64encode(var.registry_password)
  reg_server_b64 = base64encode(var.registry_server)
  reg_username_b64 = base64encode(var.registry_username)

  app_namespace = module.f5xc.app_namespace
  utility_namespace = module.f5xc.utility_namespace
  spoke_vsite = module.f5xc.spoke_vsite
  hub_vsite = module.f5xc.hub_vsite
  utility_vsite = module.f5xc.utility_vsite
  target_url = module.f5xc.app_url

  tenant_js_ref = var.tenant_js_ref
}
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
      configuration_aliases = [ kubectl.app, kubectl.utility ]
    }
  }
}

resource "local_file" "cred" {
    content_base64 = var.ves_cred
    filename       = "${path.module}/cred.p12"
}

provider "volterra" {
  api_p12_file = local_file.cred.filename
  url          = var.api_url
}

provider "kubectl" {
  alias       = "app"
  config_path = module.volterra.app-kubecfg
  apply_retry_count = 2
}

provider "kubectl" {
  alias       = "utility"
  config_path = module.volterra.utility-kubecfg
  apply_retry_count = 2
}

module "volterra" {
  source = "./modules/volterra"

  base = var.base
  app_fqdn = var.app_fqdn
  api_url = var.api_url
  api_p12_file = "${path.module}/../cred.p12"
  spoke_site_selector = var.spoke_site_selector
  hub_site_selector = var.hub_site_selector
  utility_site_selector = var.utility_site_selector
  cred_expiry_days = var.cred_expiry_days
  bot_defense_region = var.bot_defense_region
}
 
module "virtualk8s" {
  source = "./modules/virtualk8s"
  providers = {
    kubectl.app = kubectl.app
    kubectl.utility = kubectl.utility
  }
 
  reg_server = var.registry_server
  reg_password_b64 = base64encode(var.registry_password)
  reg_server_b64 = base64encode(var.registry_server)
  reg_username_b64 = base64encode(var.registry_username)

  app_namespace = module.volterra.namespace
  utility_namespace = module.volterra.utility_namespace
  spoke_vsite = module.volterra.spoke_vsite
  hub_vsite = module.volterra.hub_vsite
  utility_vsite = module.volterra.utility_vsite
  target_url = module.volterra.app_url

  tenant_js_ref = var.tenant_js_ref
}
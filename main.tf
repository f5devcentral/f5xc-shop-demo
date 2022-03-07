terraform {
  required_version = ">= 0.13"
}

resource "local_file" "cred" {
    content_base64 = var.ves_cred
    filename       = "${path.module}/../cred/cred.p12"
}

module "volterra" {
  source = "./modules/volterra"

  base = var.base
  app_fqdn = var.app_fqdn
  api_url = var.api_url
  api_p12_file = local_file.cred.filename
  spoke_site_selector = var.spoke_site_selector
  hub_site_selector = var.hub_site_selector
  utility_site_selector = var.utility_site_selector
  cred_expiry_days = var.cred_expiry_days
  bot_defense_region = var.bot_defense_region
}
 
module "app-kubectl" {
  source = "./modules/app-kubectl"

  reg_server = var.registry_server
  reg_password_b64 = base64encode(var.registry_password)
  reg_server_b64 = base64encode(var.registry_server)
  reg_username_b64 = base64encode(var.registry_username)

  namespace = module.volterra.namespace
  spoke_vsite = module.volterra.spoke_vsite
  hub_vsite = module.volterra.hub_vsite

  tenant_js_ref = var.tenant_js_ref
  
  kubecfg = module.volterra.kubecfg
}

module "utility-kubectl" {
  source = "./modules/utility-kubectl"

  reg_server = var.registry_server
  reg_password_b64 = base64encode(var.registry_password)
  reg_server_b64 = base64encode(var.registry_server)
  reg_username_b64 = base64encode(var.registry_username)

  utility_namespace = module.volterra.utility_namespace
  utility_vsite = module.volterra.utility_vsite
  
  utility_kubecfg = module.volterra.utility_kubecfg
  target_url = module.volterra.app_url
}
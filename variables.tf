variable "api_url" {
  default = "https://tenant.ves.volterra.io/api"
}

variable "api_p12_file" {
  default = "./creds/tenant.api-creds.p12"
}

variable "base" {
  default = "demo-app"
}

variable "app_fqdn" {
  default = "demo-app.tenant.example.com"
}

variable "spoke_site_selector" {
  default = ["ves.io/siteName in (ves-io-ny8-nyc, ves-io-wes-sea)"]
}

variable "hub_site_selector" {
  default = ["ves.io/siteName in (ves-io-dc12-ash)"]
}

variable "utility_site_selector" {
  default = ["ves.io/siteName in (ves-io-dc12-ash)"]
}

variable "cred_expiry_days" {
  default = 89
}

variable "registry_server" {
  default = "some_registry.example.com"
}

variable "registry_config_json" {
  default     = "b64 encoded json"
  description = "registry config data string in type kubernetes.io/dockerconfigjson"
}

variable "enable_bot_defense" {
  default = True
}

variable "bot_defense_region" {
  default = "US"
}

variable "tenant_js_ref" {
  default = "volt-f5_sales_demo_rljyvvmw-49301db1"
}
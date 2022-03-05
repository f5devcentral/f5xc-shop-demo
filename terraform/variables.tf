variable "base" {
    default = "demo-app"
}

variable "app_fqdn" {
    default = "demo-app.tenant.example.com"
}

variable "api_url" {
  default = "https://tenant.ves.volterra.io/api"
}

variable "api_p12_file" {
  default = "./creds/tenant.api-creds.p12"
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

variable "registry_password" {
    default = "2string:///some_b64e_password"
}

variable "registry_username" {
    default = "some_user"
}

variable "registry_server" {
    default = "some_registry.example.com"
}

variable "bot_defense_region" {
    default = "US"
}

variable "tenant_js_ref" {
    default = "volt-f5_sales_demo_rljyvvmw-49301db1"
}
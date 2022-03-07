variable "base" {
}

variable "app_fqdn" {
}

variable "api_url" {
}

variable "api_p12_file" {
    default = "${path.module}/../cred/cred.p12"
}

variable "spoke_site_selector" {
}

variable "hub_site_selector" {
}

variable "utility_site_selector" {
}

variable "cred_expiry_days" {    
}

variable "bot_defense_region" {
}

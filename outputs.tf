output "app_url" {
  description = "FQDN VIP to access the web app"
  value       = module.f5xc.app_url
}
output "app_url" {
  description = "FQDN VIP to access the web app"
  value       = module.volterra.app_url
}
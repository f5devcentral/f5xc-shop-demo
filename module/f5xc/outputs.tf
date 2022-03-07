output "app_url" {
  description = "Domain VIP to access the web app"
  value       = format("https://%s", var.app_fqdn)
}

output "app_namespace" {
  description = "Namespace created for this app"
  value       = volterra_namespace.ns.name
}

output "utility_namespace" {
  description = "Namespace created for loadgen and utilities"
  value       = volterra_namespace.utility_ns.name
}

output "spoke_vsite" {
  description = "Virtual site for the application"
  value       = volterra_virtual_site.spoke.name
}

output "hub_vsite" {
  description = "Virtual site for the hub services"
  value       = volterra_virtual_site.hub.name
}

output "utility_vsite" {
  description = "Virtual site for the utility services"
  value       = volterra_virtual_site.utility.name
}

output "app_kubecfg" {
  description = "kubeconfig for app vk8s"
  value       = base64decode(volterra_api_credential.app_vk8s_cred.data)
  sensitive   = true
}

output "utility_kubecfg" {
  description = "kubeconfig for utility vk8s"
  value       = base64decode(volterra_api_credential.utility_vk8s_cred.data)
  sensitive   = true
}

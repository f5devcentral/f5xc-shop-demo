output "app_url" {
  description = "Domain VIP to access the web app"
  value       = format("https://%s", var.app_fqdn)
}

output "namespace" {
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

output "kubecfg" {
  description = "kubeconfig file"
  value       = local_file.kubeconfig
}

output "utility_kubecfg" {
  description = "kubeconfig file for utility vk8s"
  value       = local_file.utility_kubeconfig
}

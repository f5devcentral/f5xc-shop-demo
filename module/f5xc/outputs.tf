output "app_url" {
  description = "Domain VIP to access the web app"
  value       = format("https://%s", var.app_fqdn)
}

output "app_namespace" {
  description = "Namespace created for this app"
  value       = volterra_namespace.app_ns.name
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

output "app_kubecfg_host" {
  description = "host value from app kubeconfig"
  value       = yamldecode(base64decode(volterra_api_credential.app_vk8s_cred.data))["clusters"][0]["cluster"]["server"]
  sensitive   = false
}

output "app_vk8s" {
  value = volterra_virtual_k8s.app_vk8s.id
}

output "utility_vk8s" {
  value = volterra_virtual_k8s.utility_vk8s.id
}

output "app_kubecfg_cluster_ca" {
  description = "cluster ca value from app kubeconfig"
  value       = yamldecode(base64decode(volterra_api_credential.app_vk8s_cred.data))["clusters"][0]["cluster"]["certificate-authority-data"]
  sensitive   = true
}

output "app_kubecfg_client_cert" {
  description = "cluster cert value from app kubeconfig"
  value       = yamldecode(base64decode(volterra_api_credential.app_vk8s_cred.data))["users"][0]["user"]["client-certificate-data"]
  sensitive   = true
}

output "app_kubecfg_client_key" {
  description = "client key value from app kubeconfig"
  value       = yamldecode(base64decode(volterra_api_credential.app_vk8s_cred.data))["users"][0]["user"]["client-key-data"]
  sensitive   = true
}

output "utility_kubecfg_host" {
  description = "host value from app kubeconfig"
  value       = yamldecode(base64decode(volterra_api_credential.utility_vk8s_cred.data))["clusters"][0]["cluster"]["server"]
  sensitive   = false
}

output "utility_kubecfg_cluster_ca" {
  description = "cluster ca value from app kubeconfig"
  value       = yamldecode(base64decode(volterra_api_credential.utility_vk8s_cred.data))["clusters"][0]["cluster"]["certificate-authority-data"]
  sensitive   = true
}

output "utility_kubecfg_client_cert" {
  description = "cluster cert value from app kubeconfig"
  value       = yamldecode(base64decode(volterra_api_credential.utility_vk8s_cred.data))["users"][0]["user"]["client-certificate-data"]
  sensitive   = true
}

output "utility_kubecfg_client_key" {
  description = "client key value from app kubeconfig"
  value       = yamldecode(base64decode(volterra_api_credential.utility_vk8s_cred.data))["users"][0]["user"]["client-key-data"]
  sensitive   = true
}
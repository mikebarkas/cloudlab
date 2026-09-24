
output "aci_ip_address" {
  value       = azurerm_container_group.auto-corp-cg.ip_address
  description = "The IP address for the container instance group."
}

output "aci_fqdn" {
  value       = azurerm_container_group.auto-corp-cg.fqdn
  description = "The FQDN of the cg from dns_name_label."
}

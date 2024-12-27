output "public_ip" {
  value       = azurerm_public_ip.netob-pip.ip_address
  description = "The public IP of the OAuth Proxy Server"
}
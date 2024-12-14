output "webapp_url" {
  value = azurerm_linux_web_app.azurewebapp.default_hostname
  description = "The hostname of the webapp"
}

output "webapp_ips" {
  value = azurerm_linux_web_app.azurewebapp.outbound_ip_addresses
  description = "The IP of the webapp"
}
# изпълняваме terraform fmt + terraform validate

# логваме се в azure с команда az login
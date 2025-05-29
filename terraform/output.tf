output "web_app_url" {
  description = "Deployed Web App URL"
  value       = "https://${azurerm_linux_web_app.app.default_hostname}"
}

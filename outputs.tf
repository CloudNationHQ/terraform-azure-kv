output "vault" {
  description = "contains all key vault config"
  value       = azurerm_key_vault.keyvault
}

output "subscriptionId" {
  description = "contains the current subscription id"
  value       = data.azurerm_subscription.current.subscription_id
}

output "keys" {
  description = "contains all keys"
  value       = azurerm_key_vault_key.kv_keys
}

output "secrets" {
  description = "contains all secrets"
  value       = azurerm_key_vault_secret.secret
}

output "certs" {
  description = "contains all certificates"
  value       = azurerm_key_vault_certificate.cert
}

output "tls_public_keys" {
  description = "contains all tls public keys"
  value       = azurerm_key_vault_secret.tls_public_key_secret
}

output "tls_private_keys" {
  description = "contains all tls private keys"
  sensitive   = true
  value       = azurerm_key_vault_secret.tls_private_key_secret
}

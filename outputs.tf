output "vault" {
  description = "contains all key vault config"
  value       = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"] : azurerm_key_vault.this["this"]
}

output "keys" {
  description = "contains all keys"
  value       = azurerm_key_vault_key.this
}

output "secrets" {
  description = "contains all secrets"
  value       = azurerm_key_vault_secret.this
}

output "certs" {
  description = "contains all certificates"
  value       = azurerm_key_vault_certificate.this
}

output "tls_public_keys" {
  description = "contains all tls public keys"
  value = {
    for key, value in azurerm_key_vault_secret.tls :
    trimsuffix(key, "-pub") => value
    if endswith(key, "-pub")
  }
}

output "tls_private_keys" {
  description = "contains all tls private keys"
  sensitive   = true
  value = {
    for key, value in azurerm_key_vault_secret.tls :
    trimsuffix(key, "-priv") => value
    if endswith(key, "-priv")
  }
}

output "policies" {
  description = "contains all key vault access policies"
  value       = azurerm_key_vault_access_policy.this
}

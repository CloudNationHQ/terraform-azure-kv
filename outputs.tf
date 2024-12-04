output "vault" {
  description = "contains all key vault config"
  value       = azurerm_key_vault.keyvault
}

output "keys" {
  description = "contains all keys"
  value       = azurerm_key_vault_key.kv_keys
}

output "secrets" {
  description = "contains all secrets"
  value       = azurerm_key_vault_secret.secrets
}

output "certs" {
  description = "contains all certificates"
  value       = azurerm_key_vault_certificate.cert
}

output "tls_public_keys" {
  description = "contains all tls public keys"
  value = {
    for key, value in azurerm_key_vault_secret.tls_secrets :
    trimsuffix(key, "-pub") => value
    if endswith(key, "-pub")
  }
}

output "tls_private_keys" {
  description = "contains all tls private keys"
  sensitive   = true
  value = {
    for key, value in azurerm_key_vault_secret.tls_secrets :
    trimsuffix(key, "-priv") => value
    if endswith(key, "-priv")
  }
}

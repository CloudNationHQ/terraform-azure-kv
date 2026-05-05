moved {
  from = azurerm_key_vault.keyvault
  to   = azurerm_key_vault.this["this"]
}

moved {
  from = azurerm_key_vault_secret.secrets
  to   = azurerm_key_vault_secret.this
}

moved {
  from = azurerm_key_vault_certificate_issuer.issuer
  to   = azurerm_key_vault_certificate_issuer.this
}

moved {
  from = azurerm_key_vault_certificate_contacts.contact
  to   = azurerm_key_vault_certificate_contacts.this
}

moved {
  from = azurerm_key_vault_key.kv_keys
  to   = azurerm_key_vault_key.this
}

moved {
  from = random_password.password
  to   = random_password.this
}

moved {
  from = tls_private_key.tls_key
  to   = tls_private_key.this
}

moved {
  from = azurerm_key_vault_certificate.cert
  to   = azurerm_key_vault_certificate.this
}

moved {
  from = azurerm_key_vault_access_policy.policy
  to   = azurerm_key_vault_access_policy.this
}

moved {
  from = azurerm_private_endpoint.endpoint
  to   = azurerm_private_endpoint.this
}

moved {
  from = azurerm_key_vault_secret.tls_secrets
  to   = azurerm_key_vault_secret.tls
}

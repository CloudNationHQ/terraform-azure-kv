locals {
  issuers = flatten([
    for issuer_key, issuer in try(var.vault.issuers, {}) : {

      issuer_key    = issuer_key
      name          = "issuer-${issuer_key}"
      key_vault_id  = azurerm_key_vault.keyvault.id
      provider_name = issuer_key
      account_id    = try(issuer.account_id, null)
      password      = try(issuer.password, null)
      org_id        = try(issuer.org_id, null)
    }
  ])
}

locals {
  keys = flatten([
    for k_key, k in try(var.vault.keys, {}) : {

      k_key           = k_key
      name            = try(k.name, join("-", [var.naming.key_vault_key, k_key]))
      key_type        = k.key_type
      key_opts        = k.key_opts
      key_size        = try(k.key_size, null)
      curve           = try(k.curve, null)
      not_before_date = try(k.not_before_date, null)
      expiration_date = try(k.expiration_date, null)
      key_vault_id    = azurerm_key_vault.keyvault.id
      rotation_policy = try(k.rotation_policy, null)
      tags            = try(k.tags, var.tags, null)
    }
  ])
}

locals {
  secrets_random = flatten([
    for secret_key, secret in try(var.vault.secrets.random_string, {}) : {

      secret_key      = secret_key
      name            = try(secret.name, join("-", [var.naming.key_vault_secret, secret_key]))
      length          = secret.length
      special         = try(secret.special, true)
      min_lower       = try(secret.min_lower, 5)
      min_upper       = try(secret.min_upper, 7)
      min_special     = try(secret.min_special, 4)
      min_numeric     = try(secret.min_numeric, 5)
      key_vault_id    = azurerm_key_vault.keyvault.id
      tags            = try(secret.tags, var.tags, null)
      content_type    = try(secret.content_type, null)
      expiration_date = try(secret.expiration_date, null)
      not_before_date = try(secret.not_before_date, null)
    }
  ])
  secrets = flatten([
    for secret_key, secret in lookup(var.vault, "secrets", {}) : {

      secret_key      = secret_key
      name            = try(secret.name, join("-", [var.naming.key_vault_secret, secret_key]))
      value           = secret.value
      key_vault_id    = azurerm_key_vault.keyvault.id
      tags            = try(secret.tags, var.tags, null)
      content_type    = try(secret.content_type, null)
      expiration_date = try(secret.expiration_date, null)
      not_before_date = try(secret.not_before_date, null)
    }
  if secret_key != "random_string" && secret_key != "tls_keys"])
}

locals {
  tls = flatten([
    for tls_key, tls in try(var.vault.secrets.tls_keys, {}) : {
      tls_key         = tls_key
      algorithm       = tls.algorithm
      name            = try(tls.name, join("-", [var.naming.key_vault_secret, tls_key]))
      rsa_bits        = try(tls.rsa_bits, 2048)
      key_vault_id    = azurerm_key_vault.keyvault.id
      tags            = try(tls.tags, var.tags, null)
      content_type    = try(tls.content_type, null)
      expiration_date = try(tls.expiration_date, null)
      not_before_date = try(tls.not_before_date, null)
    }
  ])
}

locals {
  certs = flatten([
    for cert_key, cert in try(var.vault.certs, {}) : {

      cert_key           = cert_key
      name               = try(cert.name, join("-", [var.naming.key_vault_certificate, cert_key]))
      issuer             = cert.issuer
      exportable         = cert.exportable
      key_type           = try(cert.key_type, "RSA")
      key_size           = try(cert.key_size, "2048")
      reuse_key          = try(cert.reuse_key, false)
      content_type       = try(cert.content_type, "application/x-pkcs12")
      key_usage          = cert.key_usage
      subject            = cert.subject
      validity_in_months = cert.validity_in_months
      key_vault_id       = azurerm_key_vault.keyvault.id
      tags               = try(cert.tags, var.tags, null)
    }
  ])
}

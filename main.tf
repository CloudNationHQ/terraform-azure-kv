data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# keyvault
resource "azurerm_key_vault" "keyvault" {
  name                            = var.vault.name
  resource_group_name             = coalesce(lookup(var.vault, "resourcegroup", null), var.resourcegroup)
  location                        = coalesce(lookup(var.vault, "location", null), var.location)
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = try(var.vault.sku, "standard")
  tags                            = try(var.vault.tags, var.tags, null)
  enabled_for_deployment          = try(var.vault.enabled_for_deployment, true)
  enabled_for_disk_encryption     = try(var.vault.enabled_for_disk_encryption, true)
  enabled_for_template_deployment = try(var.vault.enabled_for_template_deployment, true)
  purge_protection_enabled        = try(var.vault.purge_protection_enabled, true)
  enable_rbac_authorization       = try(var.vault.enable_rbac_authorization, true)
  public_network_access_enabled   = try(var.vault.public_network_access_enabled, true)
  soft_delete_retention_days      = try(var.vault.soft_delete_retention_in_days, null)

  dynamic "network_acls" {
    for_each = try(var.vault.network_acl, null) != null ? { "default" = var.vault.network_acl } : {}

    content {
      bypass                     = try(network_acls.value.bypass, "AzureServices")
      default_action             = try(network_acls.value.default_action, "Deny")
      ip_rules                   = try(network_acls.value.ip_rules, null)
      virtual_network_subnet_ids = try(network_acls.value.virtual_network_subnet_ids, null)
    }
  }

  lifecycle {
    ignore_changes = [
      contact,
    ]
  }
}

# role assignments
resource "azurerm_role_assignment" "admins" {
  for_each = toset(
    length(lookup(var.vault, "admins", [])) > 0 ? lookup(var.vault, "admins", []) : [data.azurerm_client_config.current.object_id]
  )

  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

# certificate issuers
resource "azurerm_key_vault_certificate_issuer" "issuer" {
  for_each = {
    for issuer in local.issuers : issuer.issuer_key => issuer
  }

  name          = each.value.name
  org_id        = each.value.org_id
  key_vault_id  = each.value.key_vault_id
  provider_name = each.value.provider_name
  account_id    = each.value.account_id
  password      = each.value.password #pat certificate authority

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

# certificate contacts
resource "azurerm_key_vault_certificate_contacts" "example" {
  for_each = try(var.vault.contacts, {}) != {} ? { "default" : {} } : {}

  key_vault_id = azurerm_key_vault.keyvault.id

  dynamic "contact" {
    for_each = {
      for k, v in try(var.vault.contacts, {}) : k => v
    }

    content {
      email = contact.value.email
      name  = try(contact.value.name, null)
      phone = try(contact.value.phone, null)
    }
  }

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

# keys
resource "azurerm_key_vault_key" "kv_keys" {
  for_each = {
    for key in local.keys : key.k_key => key
  }

  name            = each.value.name
  key_vault_id    = each.value.key_vault_id
  key_type        = each.value.key_type
  key_size        = each.value.key_size
  key_opts        = each.value.key_opts
  curve           = each.value.curve
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date
  tags            = each.value.tags

  dynamic "rotation_policy" {
    for_each = try(each.value.rotation_policy, null) != null ? { "default" = each.value.rotation_policy } : {}

    content {
      expire_after         = try(rotation_policy.value.expire_after, null)
      notify_before_expiry = try(rotation_policy.value.notify_before_expiry, null)

      dynamic "automatic" {
        for_each = try(rotation_policy.value.automatic, null) != null ? { "default" = rotation_policy.value.automatic } : {}
        content {
          time_after_creation = try(automatic.value.time_after_creation, null)
          time_before_expiry  = try(automatic.value.time_before_expiry, null)
        }
      }
    }
  }

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

# random passwords
resource "random_password" "password" {
  for_each = {
    for secret in local.secrets_random : secret.secret_key => secret
  }

  length      = each.value.length
  special     = each.value.special
  min_lower   = each.value.min_lower
  min_upper   = each.value.min_upper
  min_special = each.value.min_special
  min_numeric = each.value.min_numeric
}

resource "azurerm_key_vault_secret" "secret_random" {
  for_each = {
    for secret in local.secrets_random : secret.secret_key => secret
  }

  name            = each.value.name
  value           = random_password.password[each.key].result
  key_vault_id    = each.value.key_vault_id
  tags            = each.value.tags
  content_type    = each.value.content_type
  expiration_date = each.value.expiration_date
  not_before_date = each.value.not_before_date

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = {
    for secret in local.secrets : secret.secret_key => secret
  }

  name            = each.value.name
  value           = each.value.value
  key_vault_id    = each.value.key_vault_id
  tags            = each.value.tags
  content_type    = each.value.content_type
  expiration_date = each.value.expiration_date
  not_before_date = each.value.not_before_date

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

# tls keys
resource "tls_private_key" "tls_key" {
  for_each = {
    for key in local.tls : key.tls_key => key
  }

  algorithm = each.value.algorithm
  rsa_bits  = each.value.rsa_bits
}

resource "azurerm_key_vault_secret" "tls_public_key_secret" {
  for_each = {
    for item in local.tls : item.tls_key => item
  }

  name            = "${each.value.name}-pub"
  value           = tls_private_key.tls_key[each.key].public_key_openssh
  key_vault_id    = each.value.key_vault_id
  tags            = each.value.tags
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date
  content_type    = each.value.content_type

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

resource "azurerm_key_vault_secret" "tls_private_key_secret" {
  for_each = {
    for item in local.tls : item.tls_key => item
  }

  name            = "${each.value.name}-priv"
  value           = tls_private_key.tls_key[each.key].private_key_pem
  key_vault_id    = each.value.key_vault_id
  tags            = each.value.tags
  content_type    = each.value.content_type
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

# certificates
resource "azurerm_key_vault_certificate" "cert" {
  for_each = {
    for cert in local.certs : cert.cert_key => cert
  }

  name         = each.value.name
  key_vault_id = each.value.key_vault_id
  tags         = each.value.tags

  certificate_policy {
    issuer_parameters {
      name = each.value.issuer
    }
    key_properties {
      exportable = each.value.issuer == "Self" ? true : false
      key_type   = each.value.key_type
      key_size   = each.value.key_size
      reuse_key  = each.value.reuse_key
    }
    secret_properties {
      content_type = each.value.content_type
    }
    x509_certificate_properties {
      subject            = each.value.subject
      validity_in_months = each.value.validity_in_months
      key_usage          = each.value.key_usage
    }
  }
  depends_on = [
    azurerm_role_assignment.admins
  ]
}

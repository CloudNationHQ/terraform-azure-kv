data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

# keyvault
resource "azurerm_key_vault" "keyvault" {
  name                = var.vault.name
  resource_group_name = var.vault.resourcegroup
  location            = var.vault.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = try(var.vault.sku, "standard")

  enabled_for_deployment          = try(var.vault.enable.deployment, true)
  enabled_for_disk_encryption     = try(var.vault.enable.disk_encryption, true)
  enabled_for_template_deployment = try(var.vault.enable.template_deployment, true)
  purge_protection_enabled        = try(var.vault.enable.purge_protection, true)
  enable_rbac_authorization       = try(var.vault.enforce_rbac_auth, true)
  public_network_access_enabled   = try(var.vault.enable.public_network_access, true)
  soft_delete_retention_days      = try(var.vault.retention_in_days, null)

  lifecycle {
    ignore_changes = [
      contact,
    ]
  }
}

# role assignments
resource "azurerm_role_assignment" "current" {
  scope                = azurerm_key_vault.keyvault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
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
  password      = each.value.password //pat certificate authority

  depends_on = [
    azurerm_role_assignment.current
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
    azurerm_role_assignment.current
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
    azurerm_role_assignment.current
  ]
}

# random passwords
resource "random_password" "password" {
  for_each = {
    for secret in local.secrets : secret.secret_key => secret
  }

  length      = each.value.length
  special     = each.value.special
  min_lower   = each.value.min_lower
  min_upper   = each.value.min_upper
  min_special = each.value.min_special
  min_numeric = each.value.min_numeric
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = {
    for secret in local.secrets : secret.secret_key => secret
  }

  name         = each.value.name
  value        = random_password.password[each.key].result
  key_vault_id = each.value.key_vault_id

  depends_on = [
    azurerm_role_assignment.current
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

  name         = "${each.value.name}-pub"
  value        = tls_private_key.tls_key[each.key].public_key_openssh
  key_vault_id = each.value.key_vault_id

  depends_on = [
    azurerm_role_assignment.current
  ]
}

resource "azurerm_key_vault_secret" "tls_private_key_secret" {
  for_each = {
    for item in local.tls : item.tls_key => item
  }

  name         = "${each.value.name}-priv"
  value        = tls_private_key.tls_key[each.key].private_key_pem
  key_vault_id = each.value.key_vault_id

  depends_on = [
    azurerm_role_assignment.current
  ]
}

# certificates
resource "azurerm_key_vault_certificate" "cert" {
  for_each = {
    for cert in local.certs : cert.cert_key => cert
  }

  name         = each.value.name
  key_vault_id = each.value.key_vault_id

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
    azurerm_role_assignment.current
  ]
}

# private endpoint
resource "azurerm_private_endpoint" "endpoint" {
  for_each = contains(keys(var.vault), "private_endpoint") ? { "default" = var.vault.private_endpoint } : {}

  name                = var.vault.private_endpoint.name
  location            = var.vault.location
  resource_group_name = var.vault.resourcegroup
  subnet_id           = var.vault.private_endpoint.subnet

  private_service_connection {
    name                           = "endpoint"
    is_manual_connection           = try(each.value.is_manual_connection, false)
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names              = each.value.subresources
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = var.vault.private_endpoint.dns_zones
  }
}

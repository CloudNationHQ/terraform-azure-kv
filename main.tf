data "azurerm_client_config" "current" {}

# keyvault
resource "azurerm_key_vault" "keyvault" {
  name                            = var.vault.name
  resource_group_name             = coalesce(lookup(var.vault, "resource_group", null), var.resource_group)
  location                        = coalesce(lookup(var.vault, "location", null), var.location)
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = try(var.vault.sku_name, "standard")
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
  for_each = try(
    var.vault.issuers, {}
  )

  name          = try(each.value.name, each.key)
  key_vault_id  = azurerm_key_vault.keyvault.id
  provider_name = try(each.value.provider_name, each.key)
  account_id    = try(each.value.account_id, null)
  password      = try(each.value.password, null)
  org_id        = try(each.value.org_id, null)

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
  for_each = try(
    var.vault.keys, {}
  )

  name            = try(each.value.name, join("-", [var.naming.key_vault_key, each.key]))
  key_vault_id    = azurerm_key_vault.keyvault.id
  key_type        = each.value.key_type
  key_size        = try(each.value.key_size, null)
  key_opts        = each.value.key_opts
  curve           = try(each.value.curve, null)
  not_before_date = try(each.value.not_before_date, null)
  expiration_date = try(each.value.expiration_date, null)
  tags            = try(each.value.tags, var.tags, null)

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

# Random password generator
resource "random_password" "password" {
  for_each = try(
    var.vault.secrets.random_string, {}
  )

  length      = each.value.length
  special     = try(each.value.special, true)
  min_lower   = try(each.value.min_lower, 5)
  min_upper   = try(each.value.min_upper, 7)
  min_special = try(each.value.min_special, 4)
  min_numeric = try(each.value.min_numeric, 5)
}

# secrets
resource "azurerm_key_vault_secret" "secrets" {
  for_each = merge(
    # random password secrets
    {
      for k, v in try(
        var.vault.secrets.random_string, {}
        ) : k => {

        name            = try(v.name, join("-", [var.naming.key_vault_secret, k]))
        value           = random_password.password[k].result
        tags            = try(v.tags, var.tags, null)
        content_type    = try(v.content_type, null)
        expiration_date = try(v.expiration_date, null)
        not_before_date = try(v.not_before_date, null)
      }
    },
    # defined secrets
    {
      for k, v in lookup(
        var.vault, "secrets", {}
        ) : k => {

        name            = try(v.name, join("-", [var.naming.key_vault_secret, k]))
        value           = v.value
        tags            = try(v.tags, var.tags, null)
        content_type    = try(v.content_type, null)
        expiration_date = try(v.expiration_date, null)
        not_before_date = try(v.not_before_date, null)
      }
      if k != "random_string" && k != "tls_keys"
    }
  )

  name            = each.value.name
  value           = each.value.value
  key_vault_id    = azurerm_key_vault.keyvault.id
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
  for_each = try(
    var.vault.secrets.tls_keys, {}
  )

  algorithm = each.value.algorithm
  rsa_bits  = try(each.value.rsa_bits, 2048)
}

resource "azurerm_key_vault_secret" "tls_secrets" {
  for_each = merge(
    # public keys
    {
      for k, v in try(
        var.vault.secrets.tls_keys, {}
        ) : "${k}-pub" => {

        name            = "${try(v.name, join("-", [var.naming.key_vault_secret, k]))}-pub"
        value           = tls_private_key.tls_key[k].public_key_openssh
        key_vault_id    = azurerm_key_vault.keyvault.id
        tags            = try(v.tags, var.tags, null)
        content_type    = try(v.content_type, null)
        expiration_date = try(v.expiration_date, null)
        not_before_date = try(v.not_before_date, null)
      }
    },
    # private keys
    {
      for k, v in try(
        var.vault.secrets.tls_keys, {}
        ) : "${k}-priv" => {

        name            = "${try(v.name, join("-", [var.naming.key_vault_secret, k]))}-priv"
        value           = tls_private_key.tls_key[k].private_key_pem
        key_vault_id    = azurerm_key_vault.keyvault.id
        tags            = try(v.tags, var.tags, null)
        content_type    = try(v.content_type, null)
        expiration_date = try(v.expiration_date, null)
        not_before_date = try(v.not_before_date, null)
      }
    }
  )

  name            = each.value.name
  value           = each.value.value
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
  for_each = try(
    var.vault.certs, {}
  )

  name         = try(each.value.name, join("-", [var.naming.key_vault_certificate, each.key]))
  key_vault_id = azurerm_key_vault.keyvault.id
  tags         = try(each.value.tags, var.tags, null)

  dynamic "certificate" {
    for_each = try(each.value.certificate, null) != null ? [each.value.certificate] : []

    content {
      contents = certificate.value.contents
      password = try(certificate.value.password, null)
    }
  }

  dynamic "certificate_policy" {
    for_each = try(each.value.certificate, null) == null ? [each.value] : []

    content {
      issuer_parameters {
        name = try(
          certificate_policy.value.issuer, "Self"
        )
      }

      key_properties {
        exportable = certificate_policy.value.issuer == "Self" ? true : false
        key_type   = try(certificate_policy.value.key_type, "RSA")
        key_size   = try(certificate_policy.value.key_size, "2048")
        reuse_key  = try(certificate_policy.value.reuse_key, false)
        curve      = try(certificate_policy.value.curve, null)
      }

      secret_properties {
        content_type = try(certificate_policy.value.content_type, "application/x-pkcs12")
      }

      x509_certificate_properties {
        subject            = certificate_policy.value.subject
        validity_in_months = certificate_policy.value.validity_in_months
        key_usage          = certificate_policy.value.key_usage
        extended_key_usage = try(certificate_policy.value.extended_key_usage, [])

        dynamic "subject_alternative_names" {
          for_each = try(certificate_policy.value.subject_alternative_names, null) != null ? [certificate_policy.value.subject_alternative_names] : []

          content {
            dns_names = try(subject_alternative_names.value.dns_names, [])
            upns      = try(subject_alternative_names.value.upns, [])
            emails    = try(subject_alternative_names.value.emails, [])
          }
        }
      }

      dynamic "lifetime_action" {
        for_each = try(
          certificate_policy.value.lifetime_actions, {}
        )

        content {
          action {
            action_type = lifetime_action.value.action_type
          }

          trigger {
            days_before_expiry  = try(lifetime_action.value.days_before_expiry, null)
            lifetime_percentage = try(lifetime_action.value.lifetime_percentage, null)
          }
        }
      }
    }
  }
  depends_on = [
    azurerm_role_assignment.admins
  ]
}

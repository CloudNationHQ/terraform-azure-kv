data "azurerm_client_config" "current" {}

# keyvault
resource "azurerm_key_vault" "keyvault" {
  name                            = var.vault.name
  resource_group_name             = coalesce(lookup(var.vault, "resource_group_name", null), var.resource_group_name)
  location                        = coalesce(lookup(var.vault, "location", null), var.location)
  tenant_id                       = try(var.vault.tenant_id, null) != null ? var.vault.tenant_id : data.azurerm_client_config.current.tenant_id
  sku_name                        = var.vault.sku_name
  tags                            = coalesce(var.vault.tags, var.tags)
  enabled_for_deployment          = var.vault.enabled_for_deployment
  enabled_for_disk_encryption     = var.vault.enabled_for_disk_encryption
  enabled_for_template_deployment = var.vault.enabled_for_template_deployment
  purge_protection_enabled        = var.vault.purge_protection_enabled
  enable_rbac_authorization       = var.vault.enable_rbac_authorization
  public_network_access_enabled   = var.vault.public_network_access_enabled
  soft_delete_retention_days      = var.vault.soft_delete_retention_days

  dynamic "network_acls" {
    for_each = try(var.vault.network_acls, null) != null ? { "default" = var.vault.network_acls } : {}

    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }
}

# role assignments
resource "azurerm_role_assignment" "admins" {
  for_each = (
    var.vault.enable_role_assignment == true ? var.vault.admins != null ?
    { for admin in var.vault.admins : admin => admin } :
    { (data.azurerm_client_config.current.object_id) = data.azurerm_client_config.current.object_id } :
    {}
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

  name          = coalesce(each.value.name, each.key)
  key_vault_id  = azurerm_key_vault.keyvault.id
  provider_name = coalesce(each.value.provider_name, each.key)
  account_id    = each.value.account_id
  password      = each.value.password
  org_id        = each.value.org_id

  dynamic "admin" {
    for_each = try(each.value.admin, null) != null ? [each.value.admin] : []

    content {
      email_address = admin.value.email_address
      first_name    = admin.value.first_name
      last_name     = admin.value.last_name
      phone         = admin.value.phone
    }
  }

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

# certificate contacts
resource "azurerm_key_vault_certificate_contacts" "contact" {
  for_each = try(var.vault.contacts, null) != null ? { "default" : {} } : {}

  key_vault_id = azurerm_key_vault.keyvault.id

  dynamic "contact" {
    for_each = {
      for k, v in try(var.vault.contacts, {}) : k => v
    }

    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
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

  name            = coalesce(each.value.name, try("${var.naming.key_vault_key}-${each.key}", each.key))
  key_vault_id    = azurerm_key_vault.keyvault.id
  key_type        = each.value.key_type
  key_size        = each.value.key_size
  key_opts        = each.value.key_opts
  curve           = each.value.curve
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date
  tags            = coalesce(each.value.tags, var.tags)

  dynamic "rotation_policy" {
    for_each = try(each.value.rotation_policy, null) != null ? { "default" = each.value.rotation_policy } : {}

    content {
      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry

      dynamic "automatic" {
        for_each = try(rotation_policy.value.automatic, null) != null ? { "default" = rotation_policy.value.automatic } : {}

        content {
          time_after_creation = automatic.value.time_after_creation
          time_before_expiry  = automatic.value.time_before_expiry
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

  length           = each.value.length
  special          = each.value.special
  min_lower        = each.value.min_lower
  min_upper        = each.value.min_upper
  min_special      = each.value.min_special
  min_numeric      = each.value.min_numeric
  keepers          = each.value.keepers
  override_special = each.value.override_special
}

# secrets
resource "azurerm_key_vault_secret" "secrets" {
  for_each = merge(
    # random password secrets
    {
      for k, v in var.vault.secrets.random_string : k => {

        name = coalesce(
          v.name,
          try("${var.naming.key_vault_secret}-${replace(k, "_", "-")}",
          replace(k, "_", "-"))
        )
        value           = random_password.password[k].result
        tags            = coalesce(v.tags, var.tags)
        content_type    = v.content_type
        expiration_date = v.expiration_date
        not_before_date = v.not_before_date
      }
    },
    # defined secrets
    {
      for k, v in var.vault.secrets.predefined_string : k => {

        name = coalesce(
          v.name,
          try("${var.naming.key_vault_secret}-${replace(k, "_", "-")}",
          replace(k, "_", "-"))
        )
        value           = v.value
        tags            = coalesce(v.tags, var.tags)
        content_type    = v.content_type
        expiration_date = v.expiration_date
        not_before_date = v.not_before_date
      }
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
  rsa_bits  = each.value.rsa_bits
}

resource "azurerm_key_vault_secret" "tls_secrets" {
  for_each = merge(
    # public keys
    {
      for k, v in try(
        var.vault.secrets.tls_keys, {}
        ) : "${k}-pub" => {

        name            = "${coalesce(v.name, "${var.naming.key_vault_secret}-${k}", k)}-pub"
        value           = tls_private_key.tls_key[k].public_key_openssh
        key_vault_id    = azurerm_key_vault.keyvault.id
        tags            = coalesce(v.tags, var.tags)
        content_type    = v.content_type
        expiration_date = v.expiration_date
        not_before_date = v.not_before_date
      }
    },
    # private keys
    {
      for k, v in try(
        var.vault.secrets.tls_keys, {}
        ) : "${k}-priv" => {

        name            = "${coalesce(v.name, "${var.naming.key_vault_secret}-${k}", k)}-priv"
        value           = tls_private_key.tls_key[k].private_key_pem
        key_vault_id    = azurerm_key_vault.keyvault.id
        tags            = coalesce(v.tags, var.tags)
        content_type    = v.content_type
        expiration_date = v.expiration_date
        not_before_date = v.not_before_date
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

  name         = coalesce(each.value.name, "${var.naming.key_vault_certificate}-${each.key}")
  key_vault_id = azurerm_key_vault.keyvault.id
  tags         = coalesce(each.value.tags, var.tags)

  dynamic "certificate" {
    for_each = try(each.value.certificate, null) != null ? [each.value.certificate] : []

    content {
      contents = certificate.value.contents
      password = certificate.value.password
    }
  }

  dynamic "certificate_policy" {
    for_each = try(each.value.certificate, null) == null ? [each.value] : []

    content {
      issuer_parameters {
        name = certificate_policy.value.issuer
      }

      key_properties {
        exportable = certificate_policy.value.issuer == "Self" ? true : false
        key_type   = certificate_policy.value.key_type
        key_size   = certificate_policy.value.key_size
        reuse_key  = certificate_policy.value.reuse_key
        curve      = certificate_policy.value.curve
      }

      secret_properties {
        content_type = certificate_policy.value.content_type
      }

      x509_certificate_properties {
        subject            = certificate_policy.value.subject
        validity_in_months = certificate_policy.value.validity_in_months
        key_usage          = certificate_policy.value.key_usage
        extended_key_usage = try(certificate_policy.value.extended_key_usage, [])

        dynamic "subject_alternative_names" {
          for_each = try(certificate_policy.value.subject_alternative_names, null) != null ? [certificate_policy.value.subject_alternative_names] : []

          content {
            dns_names = subject_alternative_names.value.dns_names
            upns      = subject_alternative_names.value.upns
            emails    = subject_alternative_names.value.emails
          }
        }
      }

      dynamic "lifetime_action" {
        for_each = try(certificate_policy.value.lifetime_action, null) != null ? [certificate_policy.value.lifetime_action] : []

        content {
          action {
            action_type = lifetime_action.value.action_type
          }

          trigger {
            days_before_expiry  = lifetime_action.value.days_before_expiry
            lifetime_percentage = lifetime_action.value.lifetime_percentage
          }
        }
      }
    }
  }
  depends_on = [
    azurerm_role_assignment.admins
  ]
}

resource "azurerm_key_vault_access_policy" "policy" {
  for_each = { for key, policy in try(
    var.vault.access_policies, {}
  ) : key => policy if var.vault.enable_rbac_authorization == false }

  key_vault_id   = azurerm_key_vault.keyvault.id
  tenant_id      = try(each.value.tenant_id, null) != null ? each.value.tenant_id : data.azurerm_client_config.current.tenant_id
  object_id      = try(each.value.object_id, null) != null ? each.value.object_id : data.azurerm_client_config.current.object_id
  application_id = each.value.application_id


  secret_permissions      = try(each.value.secret_permissions[0], []) == "all" ? local.all_secret_permissions : each.value.secret_permissions
  key_permissions         = try(each.value.key_permissions[0], []) == "all" ? local.all_key_permissions : each.value.key_permissions
  certificate_permissions = try(each.value.certificate_permissions[0], []) == "all" ? local.all_certificate_permissions : each.value.certificate_permissions
  storage_permissions     = try(each.value.storage_permissions[0], []) == "all" ? local.all_storage_permissions : each.value.storage_permissions
}

locals {
  all_key_permissions = [
    "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get",
    "Import", "List", "Purge", "Recover", "Restore", "Sign",
    "UnwrapKey", "Update", "Verify", "WrapKey", "Release",
    "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]
  all_secret_permissions = [
    "Backup", "Delete", "Get", "List",
    "Purge", "Recover", "Restore", "Set"
  ]
  all_certificate_permissions = [
    "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers",
    "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers",
    "Purge", "Recover", "Restore", "SetIssuers", "Update"
  ]
  all_storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS",
    "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
  ]
}

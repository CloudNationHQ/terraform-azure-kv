data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "this" {
  for_each = var.vault.use_existing == true ? { "this" = {} } : {}

  name = var.vault.name

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )
}

# keyvault
resource "azurerm_key_vault" "this" {
  for_each = var.vault.use_existing != true ? { "this" = {} } : {}

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.vault.location, var.location
  )

  tenant_id = coalesce(
    var.vault.tenant_id, data.azurerm_client_config.current.tenant_id
  )

  name                            = var.vault.name
  sku_name                        = var.vault.sku_name
  enabled_for_deployment          = var.vault.enabled_for_deployment
  enabled_for_disk_encryption     = var.vault.enabled_for_disk_encryption
  enabled_for_template_deployment = var.vault.enabled_for_template_deployment
  purge_protection_enabled        = var.vault.purge_protection_enabled
  rbac_authorization_enabled      = var.vault.rbac_authorization_enabled
  public_network_access_enabled   = var.vault.public_network_access_enabled
  soft_delete_retention_days      = var.vault.soft_delete_retention_days

  tags = coalesce(
    var.vault.tags, var.tags
  )

  dynamic "network_acls" {
    for_each = var.vault.network_acls != null ? { "this" = var.vault.network_acls } : {}

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
    coalesce(var.vault.enable_role_assignment, true) == true ? var.vault.admins != null ?
    { for idx, admin in var.vault.admins : tostring(idx) => admin } :
    { (data.azurerm_client_config.current.object_id) = data.azurerm_client_config.current.object_id } :
    {}
  )

  scope                = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

# private endpoints
resource "azurerm_private_endpoint" "this" {
  for_each = var.vault.private_endpoints != null ? var.vault.private_endpoints : {}

  resource_group_name = coalesce(
    var.vault.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.vault.location, var.location
  )

  name = coalesce(
    each.value.name, each.key
  )

  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.custom_network_interface_name

  tags = coalesce(
    each.value.tags, var.tags
  )

  private_service_connection {
    name = coalesce(
      each.value.private_service_connection_name, "${each.key}-connection"
    )

    is_manual_connection              = each.value.is_manual_connection
    private_connection_resource_id    = each.value.private_connection_resource_alias != null ? null : (var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id)
    private_connection_resource_alias = each.value.private_connection_resource_alias
    subresource_names                 = each.value.subresource_name != null ? [each.value.subresource_name] : ["vault"]
    request_message                   = each.value.request_message
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_resource_ids != null ? { "this" = each.value.private_dns_zone_resource_ids } : {}

    content {
      name                 = each.value.private_dns_zone_group_name
      private_dns_zone_ids = private_dns_zone_group.value
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name
      subresource_name   = ip_configuration.value.subresource_name
    }
  }
}

# certificate issuers
resource "azurerm_key_vault_certificate_issuer" "this" {
  for_each = var.vault.issuers != null ? var.vault.issuers : {}

  name = coalesce(
    each.value.name, each.key
  )

  provider_name = coalesce(
    each.value.provider_name, each.key
  )

  key_vault_id = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  account_id   = each.value.account_id
  password     = each.value.password
  org_id       = each.value.org_id

  dynamic "admin" {
    for_each = each.value.admin != null ? { "this" = each.value.admin } : {}

    content {
      email_address = admin.value.email_address
      first_name    = admin.value.first_name
      last_name     = admin.value.last_name
      phone         = admin.value.phone
    }
  }

  depends_on = [
    azurerm_role_assignment.admins,
    azurerm_private_endpoint.this
  ]
}

# certificate contacts
resource "azurerm_key_vault_certificate_contacts" "this" {
  for_each = var.vault.contacts != null ? { "this" = {} } : {}

  key_vault_id = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id

  dynamic "contact" {
    for_each = var.vault.contacts != null ? var.vault.contacts : {}

    content {
      email = contact.value.email
      name  = contact.value.name
      phone = contact.value.phone
    }
  }

  depends_on = [
    azurerm_role_assignment.admins,
    azurerm_private_endpoint.this
  ]
}

# keys
resource "azurerm_key_vault_key" "this" {
  for_each = var.vault.keys != null ? var.vault.keys : {}

  name            = coalesce(each.value.name, replace(each.key, "_", "-"))
  key_vault_id    = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  key_type        = each.value.key_type
  key_size        = each.value.key_size
  key_opts        = each.value.key_opts
  curve           = each.value.curve
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date
  tags            = coalesce(each.value.tags, var.tags)

  dynamic "rotation_policy" {
    for_each = each.value.rotation_policy != null ? { "this" = each.value.rotation_policy } : {}

    content {
      expire_after         = rotation_policy.value.expire_after
      notify_before_expiry = rotation_policy.value.notify_before_expiry

      dynamic "automatic" {
        for_each = rotation_policy.value.automatic != null ? { "this" = rotation_policy.value.automatic } : {}

        content {
          time_after_creation = automatic.value.time_after_creation
          time_before_expiry  = automatic.value.time_before_expiry
        }
      }
    }
  }

  dynamic "release_policy" {
    for_each = each.value.release_policy != null ? { "this" = each.value.release_policy } : {}

    content {
      json      = release_policy.value.json
      immutable = release_policy.value.immutable
    }
  }

  depends_on = [
    azurerm_role_assignment.admins,
    azurerm_private_endpoint.this
  ]

  lifecycle {
    ignore_changes = [
      expiration_date
    ]
  }
}

locals {
  random_strings     = var.vault.secrets == null || var.vault.secrets.random_string == null ? {} : var.vault.secrets.random_string
  predefined_strings = var.vault.secrets == null || var.vault.secrets.predefined_string == null ? {} : var.vault.secrets.predefined_string
  tls_keys           = var.vault.secrets == null || var.vault.secrets.tls_keys == null ? {} : var.vault.secrets.tls_keys

  string_secrets = merge(
    { for k, v in local.random_strings : k => {
      random          = true
      name            = coalesce(v.name, replace(k, "_", "-"))
      tags            = coalesce(v.tags, var.tags)
      content_type    = v.content_type
      expiration_date = v.expiration_date
      not_before_date = v.not_before_date
    } },
    { for k, v in local.predefined_strings : k => {
      random          = false
      name            = coalesce(v.name, replace(k, "_", "-"))
      tags            = coalesce(v.tags, var.tags)
      content_type    = v.content_type
      expiration_date = v.expiration_date
      not_before_date = v.not_before_date
    } }
  )

  tls_secrets = merge([for k, v in local.tls_keys : {
    for part in ["pub", "priv"] : "${k}-${part}" => {
      key             = k
      public          = part == "pub"
      name            = "${coalesce(v.name, replace(k, "_", "-"))}-${part}"
      tags            = coalesce(v.tags, var.tags)
      content_type    = v.content_type
      expiration_date = v.expiration_date
      not_before_date = v.not_before_date
    }
  }]...)
}

# Random password generator
resource "random_password" "this" {
  for_each = toset(
    nonsensitive(
      keys(local.random_strings)
    )
  )

  length           = local.random_strings[each.key].length
  numeric          = local.random_strings[each.key].numeric
  lower            = local.random_strings[each.key].lower
  upper            = local.random_strings[each.key].upper
  special          = local.random_strings[each.key].special
  min_lower        = local.random_strings[each.key].min_lower
  min_upper        = local.random_strings[each.key].min_upper
  min_special      = local.random_strings[each.key].min_special
  min_numeric      = local.random_strings[each.key].min_numeric
  keepers          = local.random_strings[each.key].keepers
  override_special = local.random_strings[each.key].override_special
}

# secrets
resource "azurerm_key_vault_secret" "this" {
  for_each = toset(
    nonsensitive(
      keys(local.string_secrets)
    )
  )

  name             = local.string_secrets[each.key].name
  value            = local.string_secrets[each.key].random ? random_password.this[each.key].result : local.predefined_strings[each.key].value
  value_wo         = local.string_secrets[each.key].random ? null : local.predefined_strings[each.key].value_wo
  value_wo_version = local.string_secrets[each.key].random ? null : local.predefined_strings[each.key].value_wo_version
  tags             = local.string_secrets[each.key].tags
  content_type     = local.string_secrets[each.key].content_type
  expiration_date  = local.string_secrets[each.key].expiration_date
  not_before_date  = local.string_secrets[each.key].not_before_date

  key_vault_id = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id

  depends_on = [
    azurerm_role_assignment.admins,
    azurerm_private_endpoint.this
  ]
}

# tls keys
resource "tls_private_key" "this" {
  for_each = toset(
    nonsensitive(
      keys(local.tls_keys)
    )
  )

  algorithm   = local.tls_keys[each.key].algorithm
  rsa_bits    = local.tls_keys[each.key].rsa_bits
  ecdsa_curve = local.tls_keys[each.key].ecdsa_curve
}

resource "azurerm_key_vault_secret" "tls" {
  for_each = toset(
    nonsensitive(
      keys(local.tls_secrets)
    )
  )

  value = local.tls_secrets[each.key].public ? (
    tls_private_key.this[local.tls_secrets[each.key].key].public_key_openssh
    ) : (
    tls_private_key.this[local.tls_secrets[each.key].key].private_key_pem
  )

  name            = local.tls_secrets[each.key].name
  key_vault_id    = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  tags            = local.tls_secrets[each.key].tags
  content_type    = local.tls_secrets[each.key].content_type
  not_before_date = local.tls_secrets[each.key].not_before_date
  expiration_date = local.tls_secrets[each.key].expiration_date

  depends_on = [
    azurerm_role_assignment.admins,
    azurerm_private_endpoint.this
  ]
}

# certificates
resource "azurerm_key_vault_certificate" "this" {
  for_each = var.vault.certs != null ? var.vault.certs : {}

  name         = coalesce(each.value.name, replace(each.key, "_", "-"))
  key_vault_id = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  tags         = coalesce(each.value.tags, var.tags)

  dynamic "certificate" {
    for_each = each.value.certificate != null ? { "this" = each.value.certificate } : {}

    content {
      contents = certificate.value.contents
      password = certificate.value.password
    }
  }

  dynamic "certificate_policy" {
    for_each = each.value.certificate == null ? { "this" = each.value } : {}

    content {
      issuer_parameters {
        name = certificate_policy.value.issuer
      }

      key_properties {
        exportable = coalesce(
          certificate_policy.value.exportable,
          certificate_policy.value.issuer == "Self" ? true : false
        )
        key_type  = certificate_policy.value.key_type
        key_size  = certificate_policy.value.key_size
        reuse_key = certificate_policy.value.reuse_key
        curve     = certificate_policy.value.curve
      }

      secret_properties {
        content_type = certificate_policy.value.content_type
      }

      x509_certificate_properties {
        subject            = certificate_policy.value.subject
        validity_in_months = certificate_policy.value.validity_in_months
        key_usage          = certificate_policy.value.key_usage
        extended_key_usage = (certificate_policy.value.extended_key_usage != null ? certificate_policy.value.extended_key_usage : [])

        dynamic "subject_alternative_names" {
          for_each = certificate_policy.value.subject_alternative_names != null ? { "this" = certificate_policy.value.subject_alternative_names } : {}

          content {
            dns_names = subject_alternative_names.value.dns_names
            upns      = subject_alternative_names.value.upns
            emails    = subject_alternative_names.value.emails
          }
        }
      }

      dynamic "lifetime_action" {
        for_each = certificate_policy.value.lifetime_action != null ? { "this" = certificate_policy.value.lifetime_action } : {}

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
    azurerm_role_assignment.admins,
    azurerm_private_endpoint.this
  ]
}

resource "azurerm_key_vault_access_policy" "this" {
  for_each = !var.vault.rbac_authorization_enabled ? {
    for key, policy in coalesce(var.vault.access_policies, {}) : key => merge(policy, {
      for kind, permissions in {
        key         = policy.key_permissions
        secret      = policy.secret_permissions
        certificate = policy.certificate_permissions
        storage     = policy.storage_permissions
      } : "${kind}_permissions" => try(permissions[0], "") == "all" ? local.all_permissions[kind] : coalesce(permissions, [])
    })
  } : {}

  key_vault_id = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id

  tenant_id = coalesce(
    each.value.tenant_id, data.azurerm_client_config.current.tenant_id
  )

  object_id = coalesce(
    each.value.object_id, data.azurerm_client_config.current.object_id
  )

  application_id          = each.value.application_id
  key_permissions         = each.value.key_permissions
  secret_permissions      = each.value.secret_permissions
  certificate_permissions = each.value.certificate_permissions
  storage_permissions     = each.value.storage_permissions
}

locals {
  all_permissions = {
    key = [
      "Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get",
      "Import", "List", "Purge", "Recover", "Restore", "Sign",
      "UnwrapKey", "Update", "Verify", "WrapKey", "Release",
      "Rotate", "GetRotationPolicy", "SetRotationPolicy"
    ]
    secret = [
      "Backup", "Delete", "Get", "List",
      "Purge", "Recover", "Restore", "Set"
    ]
    certificate = [
      "Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers",
      "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers",
      "Purge", "Recover", "Restore", "SetIssuers", "Update"
    ]
    storage = [
      "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS",
      "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"
    ]
  }
}

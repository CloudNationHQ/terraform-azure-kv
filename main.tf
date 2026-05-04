data "azurerm_client_config" "current" {}

data "azurerm_key_vault" "this" {
  for_each            = var.vault.use_existing == true ? { "this" = {} } : {}
  name                = var.vault.name
  resource_group_name = coalesce(var.vault.resource_group_name, var.resource_group_name)
}

# keyvault
resource "azurerm_key_vault" "this" {
  for_each                        = var.vault.use_existing != true ? { "this" = {} } : {}
  name                            = var.vault.name
  resource_group_name             = coalesce(var.vault.resource_group_name, var.resource_group_name)
  location                        = coalesce(var.vault.location, var.location)
  tenant_id                       = coalesce(var.vault.tenant_id, data.azurerm_client_config.current.tenant_id)
  sku_name                        = coalesce(var.vault.sku_name, "standard")
  tags                            = coalesce(var.vault.tags, var.tags)
  enabled_for_deployment          = coalesce(var.vault.enabled_for_deployment, true)
  enabled_for_disk_encryption     = coalesce(var.vault.enabled_for_disk_encryption, true)
  enabled_for_template_deployment = coalesce(var.vault.enabled_for_template_deployment, true)
  purge_protection_enabled        = coalesce(var.vault.purge_protection_enabled, true)
  rbac_authorization_enabled      = coalesce(var.vault.rbac_authorization_enabled, true)
  public_network_access_enabled   = var.vault.public_network_access_enabled
  soft_delete_retention_days      = var.vault.soft_delete_retention_days

  dynamic "network_acls" {
    for_each = var.vault.network_acls != null ? { "this" = var.vault.network_acls } : {}

    content {
      bypass                     = coalesce(network_acls.value.bypass, "AzureServices")
      default_action             = coalesce(network_acls.value.default_action, "Deny")
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
  for_each = (var.vault.private_endpoints != null ? var.vault.private_endpoints : {})

  resource_group_name = coalesce(var.vault.resource_group_name, var.resource_group_name)
  location            = coalesce(var.vault.location, var.location)

  name                          = coalesce(each.value.name, each.key)
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.custom_network_interface_name
  tags                          = coalesce(each.value.tags, var.tags)

  private_service_connection {
    name                           = coalesce(each.value.private_service_connection_name, "${each.key}-connection")
    is_manual_connection           = coalesce(each.value.is_manual_connection, false)
    private_connection_resource_id = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
    subresource_names              = each.value.subresource_name != null ? [each.value.subresource_name] : ["vault"]
    request_message                = each.value.request_message
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_resource_ids != null ? { "this" = each.value.private_dns_zone_resource_ids } : {}

    content {
      name                 = "default"
      private_dns_zone_ids = private_dns_zone_group.value
    }
  }

  dynamic "ip_configuration" {
    for_each = (each.value.ip_configurations != null ? each.value.ip_configurations : {})

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
  for_each = (var.vault.issuers != null ? var.vault.issuers : {})

  name          = coalesce(each.value.name, each.key)
  key_vault_id  = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  provider_name = coalesce(each.value.provider_name, each.key)
  account_id    = each.value.account_id
  password      = each.value.password
  org_id        = each.value.org_id

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
    azurerm_role_assignment.admins
  ]
}

# certificate contacts
resource "azurerm_key_vault_certificate_contacts" "this" {
  for_each = var.vault.contacts != null ? { "this" = {} } : {}

  key_vault_id = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id

  dynamic "contact" {
    for_each = (var.vault.contacts != null ? var.vault.contacts : {})

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
resource "azurerm_key_vault_key" "this" {
  for_each = (var.vault.keys != null ? var.vault.keys : {})

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

# Random password generator
resource "random_password" "this" {
  for_each = toset(nonsensitive(
    var.vault.secrets != null && var.vault.secrets.random_string != null
    ? keys(var.vault.secrets.random_string)
    : []
  ))

  length           = var.vault.secrets.random_string[each.key].length
  numeric          = var.vault.secrets.random_string[each.key].numeric
  lower            = var.vault.secrets.random_string[each.key].lower
  upper            = var.vault.secrets.random_string[each.key].upper
  special          = var.vault.secrets.random_string[each.key].special
  min_lower        = var.vault.secrets.random_string[each.key].min_lower
  min_upper        = var.vault.secrets.random_string[each.key].min_upper
  min_special      = var.vault.secrets.random_string[each.key].min_special
  min_numeric      = var.vault.secrets.random_string[each.key].min_numeric
  keepers          = var.vault.secrets.random_string[each.key].keepers
  override_special = var.vault.secrets.random_string[each.key].override_special
}

# secrets
resource "azurerm_key_vault_secret" "this" {
  for_each = nonsensitive(merge(
    { for k in keys(var.vault.secrets == null || var.vault.secrets.random_string == null ? {} : var.vault.secrets.random_string) : k => "random_string" },
    { for k in keys(var.vault.secrets == null || var.vault.secrets.predefined_string == null ? {} : var.vault.secrets.predefined_string) : k => "predefined_string" }
  ))

  name             = each.value == "random_string" ? coalesce(var.vault.secrets.random_string[each.key].name, replace(each.key, "_", "-")) : coalesce(var.vault.secrets.predefined_string[each.key].name, replace(each.key, "_", "-"))
  value            = each.value == "random_string" ? random_password.this[each.key].result : var.vault.secrets.predefined_string[each.key].value
  value_wo         = each.value == "random_string" ? null : var.vault.secrets.predefined_string[each.key].value_wo
  value_wo_version = each.value == "random_string" ? null : var.vault.secrets.predefined_string[each.key].value_wo_version
  key_vault_id     = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  tags             = each.value == "random_string" ? coalesce(var.vault.secrets.random_string[each.key].tags, var.tags) : coalesce(var.vault.secrets.predefined_string[each.key].tags, var.tags)
  content_type     = each.value == "random_string" ? var.vault.secrets.random_string[each.key].content_type : var.vault.secrets.predefined_string[each.key].content_type
  expiration_date  = each.value == "random_string" ? var.vault.secrets.random_string[each.key].expiration_date : var.vault.secrets.predefined_string[each.key].expiration_date
  not_before_date  = each.value == "random_string" ? var.vault.secrets.random_string[each.key].not_before_date : var.vault.secrets.predefined_string[each.key].not_before_date

  depends_on = [
    azurerm_role_assignment.admins,
    azurerm_private_endpoint.this
  ]
}

# tls keys
resource "tls_private_key" "this" {
  for_each = toset(nonsensitive(
    var.vault.secrets != null && var.vault.secrets.tls_keys != null
    ? keys(var.vault.secrets.tls_keys)
    : []
  ))

  algorithm   = var.vault.secrets.tls_keys[each.key].algorithm
  rsa_bits    = var.vault.secrets.tls_keys[each.key].rsa_bits
  ecdsa_curve = var.vault.secrets.tls_keys[each.key].ecdsa_curve
}

resource "azurerm_key_vault_secret" "tls" {
  for_each = nonsensitive(merge(
    { for k in(var.vault.secrets != null ? keys(coalesce(var.vault.secrets.tls_keys, {})) : []) : "${k}-pub" => "pub" },
    { for k in(var.vault.secrets != null ? keys(coalesce(var.vault.secrets.tls_keys, {})) : []) : "${k}-priv" => "priv" }
  ))

  name = "${coalesce(
    var.vault.secrets.tls_keys[trimsuffix(each.key, "-${each.value}")].name,
    replace(trimsuffix(each.key, "-${each.value}"), "_", "-")
  )}-${each.value}"
  value = each.value == "pub" ? (
    tls_private_key.this[trimsuffix(each.key, "-pub")].public_key_openssh
    ) : (
    tls_private_key.this[trimsuffix(each.key, "-priv")].private_key_pem
  )
  key_vault_id    = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  tags            = coalesce(var.vault.secrets.tls_keys[trimsuffix(each.key, "-${each.value}")].tags, var.tags)
  content_type    = var.vault.secrets.tls_keys[trimsuffix(each.key, "-${each.value}")].content_type
  not_before_date = var.vault.secrets.tls_keys[trimsuffix(each.key, "-${each.value}")].not_before_date
  expiration_date = var.vault.secrets.tls_keys[trimsuffix(each.key, "-${each.value}")].expiration_date

  depends_on = [
    azurerm_role_assignment.admins
  ]
}

# certificates
resource "azurerm_key_vault_certificate" "this" {
  for_each = (var.vault.certs != null ? var.vault.certs : {})

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
    azurerm_role_assignment.admins
  ]
}

resource "azurerm_key_vault_access_policy" "this" {
  for_each = {
    for key, policy in(var.vault.access_policies != null ? var.vault.access_policies : {}) : key => policy
    if coalesce(var.vault.rbac_authorization_enabled, true) == false
  }

  key_vault_id   = var.vault.use_existing == true ? data.azurerm_key_vault.this["this"].id : azurerm_key_vault.this["this"].id
  tenant_id      = coalesce(each.value.tenant_id, data.azurerm_client_config.current.tenant_id)
  object_id      = coalesce(each.value.object_id, data.azurerm_client_config.current.object_id)
  application_id = each.value.application_id

  secret_permissions      = try(each.value.secret_permissions[0], null) == "all" ? local.all_secret_permissions : (each.value.secret_permissions != null ? each.value.secret_permissions : [])
  key_permissions         = try(each.value.key_permissions[0], null) == "all" ? local.all_key_permissions : (each.value.key_permissions != null ? each.value.key_permissions : [])
  certificate_permissions = try(each.value.certificate_permissions[0], null) == "all" ? local.all_certificate_permissions : (each.value.certificate_permissions != null ? each.value.certificate_permissions : [])
  storage_permissions     = try(each.value.storage_permissions[0], null) == "all" ? local.all_storage_permissions : (each.value.storage_permissions != null ? each.value.storage_permissions : [])
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

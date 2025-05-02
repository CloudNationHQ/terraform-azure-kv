variable "vault" {
  description = "describes key vault related configuration"
  type = object({
    name                                   = string
    location                               = optional(string, null)
    resource_group_name                    = optional(string, null)
    enable_rbac_authorization              = optional(bool, true)
    tenant_id                              = optional(string)
    sku_name                               = optional(string, "standard")
    tags                                   = optional(map(string))
    enabled_for_deployment                 = optional(bool, true)
    enabled_for_disk_encryption            = optional(bool, true)
    enabled_for_template_deployment        = optional(bool, true)
    purge_protection_enabled               = optional(bool, true)
    public_network_access_enabled          = optional(bool, true)
    soft_delete_retention_days             = optional(number, 90)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check       = optional(bool)
    condition                              = optional(string)
    condition_version                      = optional(string)
    principal_type                         = optional(string)
    role_definition_id                     = optional(string)
    admins                                 = optional(list(string))
    enable_role_assignment                 = optional(bool, true)
    network_acls = optional(object({
      bypass                     = optional(string, "AzureServices")
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), null)
    issuers = optional(map(object({
      name          = optional(string)
      provider_name = optional(string)
      account_id    = optional(string, null)
      password      = optional(string, null)
      org_id        = optional(string, null)
    })), {})
    contacts = optional(map(object({
      email = string
      name  = optional(string, null)
      phone = optional(string, null)
    })))
    keys = optional(map(object({
      name            = optional(string)
      key_type        = string
      key_size        = optional(number, null)
      key_opts        = optional(list(string))
      curve           = optional(string, null)
      not_before_date = optional(string, null)
      expiration_date = optional(string, null)
      tags            = optional(map(string))
      rotation_policy = optional(object({
        expire_after         = optional(string, null)
        notify_before_expiry = optional(string, null)
        automatic = optional(object({
          time_after_creation = optional(string, null)
          time_before_expiry  = optional(string, null)
        }))
      }))
    })), {})
    secrets = optional(object({
      predefined_string = optional(map(object({
        value           = optional(string)
        name            = optional(string)
        tags            = optional(map(string))
        content_type    = optional(string, null)
        expiration_date = optional(string, null)
        not_before_date = optional(string, null)
      })), {})
      random_string = optional(map(object({
        name             = optional(string)
        length           = number
        special          = optional(bool, true)
        min_lower        = optional(number, 5)
        min_upper        = optional(number, 7)
        min_special      = optional(number, 4)
        min_numeric      = optional(number, 5)
        override_special = optional(string, null)
        keepers          = optional(map(string))
        tags             = optional(map(string))
        content_type     = optional(string, null)
        expiration_date  = optional(string, null)
        not_before_date  = optional(string, null)
      })), {})
      tls_keys = optional(map(object({
        name            = optional(string)
        algorithm       = string
        rsa_bits        = optional(number, 2048)
        tags            = optional(map(string))
        content_type    = optional(string, null)
        expiration_date = optional(string, null)
        not_before_date = optional(string, null)
      })), {})
    }), {})
    certs = optional(map(object({
      name = optional(string)
      tags = optional(map(string))
      certificate = optional(object({
        contents = string
        password = optional(string, null)
      }))
      issuer             = optional(string, "Self")
      key_type           = optional(string, "RSA")
      key_size           = optional(number, 2048)
      reuse_key          = optional(bool, false)
      curve              = optional(string, null)
      content_type       = optional(string, "application/x-pkcs12")
      subject            = string
      validity_in_months = number
      key_usage          = list(string)
      extended_key_usage = optional(list(string), [])
      subject_alternative_names = optional(object({
        dns_names = optional(list(string), [])
        upns      = optional(list(string), [])
        emails    = optional(list(string), [])
      }))
      lifetime_actions = optional(map(object({
        action_type         = string
        days_before_expiry  = optional(number, null)
        lifetime_percentage = optional(number, null)
      })))
    })), {})
    access_policies = optional(map(object({
      object_id               = optional(string)
      tenant_id               = optional(string)
      application_id          = optional(string, null)
      key_permissions         = optional(list(string))
      secret_permissions      = optional(list(string))
      certificate_permissions = optional(list(string))
      storage_permissions     = optional(list(string))
    })), {})
  })
}

variable "naming" {
  description = "contains naming convention"
  type = object({
    key_vault_key         = optional(string)
    key_vault_secret      = optional(string)
    key_vault_certificate = optional(string)
  })
  default = {}
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}

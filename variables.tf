variable "vault" {
  description = "describes key vault related configuration"
  type = object({
    name                            = string
    location                        = optional(string)
    resource_group_name             = optional(string)
    rbac_authorization_enabled      = optional(bool)
    tenant_id                       = optional(string)
    sku_name                        = optional(string)
    tags                            = optional(map(string))
    enabled_for_deployment          = optional(bool)
    enabled_for_disk_encryption     = optional(bool)
    enabled_for_template_deployment = optional(bool)
    purge_protection_enabled        = optional(bool)
    public_network_access_enabled   = optional(bool)
    soft_delete_retention_days      = optional(number)
    use_existing                    = optional(bool)
    admins                          = optional(list(string))
    enable_role_assignment          = optional(bool)
    network_acls = optional(object({
      bypass                     = optional(string)
      default_action             = optional(string)
      ip_rules                   = optional(list(string))
      virtual_network_subnet_ids = optional(list(string))
    }))
    private_endpoints = optional(map(object({
      name                              = optional(string)
      subnet_resource_id                = string
      subresource_name                  = optional(string)
      private_dns_zone_resource_ids     = optional(list(string))
      application_security_group_ids    = optional(list(string))
      custom_network_interface_name     = optional(string)
      tags                              = optional(map(string))
      private_service_connection_name   = optional(string)
      private_connection_resource_alias = optional(string)
      is_manual_connection              = optional(bool)
      request_message                   = optional(string)
      ip_configurations = optional(map(object({
        name               = optional(string)
        private_ip_address = optional(string)
        member_name        = optional(string)
        subresource_name   = optional(string)
      })))
      role_assignments = optional(map(object({
        role_definition_id_or_name             = string
        principal_id                           = string
        description                            = optional(string)
        skip_service_principal_aad_check       = optional(bool)
        condition                              = optional(string)
        condition_version                      = optional(string)
        delegated_managed_identity_resource_id = optional(string)
        principal_type                         = optional(string)
      })))
      lock = optional(object({
        kind = string
        name = optional(string)
      }))
    })))
    issuers = optional(map(object({
      name          = optional(string)
      provider_name = optional(string)
      account_id    = optional(string)
      password      = optional(string)
      org_id        = optional(string)
      admin = optional(map(object({
        email_address = string
        first_name    = optional(string)
        last_name     = optional(string)
        phone         = optional(string)
      })))

    })))
    contacts = optional(map(object({
      email = string
      name  = optional(string)
      phone = optional(string)
    })))
    keys = optional(map(object({
      name            = optional(string)
      key_type        = string
      key_size        = optional(number)
      key_opts        = optional(list(string))
      curve           = optional(string)
      not_before_date = optional(string)
      expiration_date = optional(string)
      tags            = optional(map(string))
      rotation_policy = optional(object({
        expire_after         = optional(string)
        notify_before_expiry = optional(string)
        automatic = optional(object({
          time_after_creation = optional(string)
          time_before_expiry  = optional(string)
        }))
      }))
      release_policy = optional(object({
        json      = string
        immutable = optional(bool)
      }))
    })))
    secrets = optional(object({
      predefined_string = optional(map(object({
        value            = optional(string)
        value_wo         = optional(string)
        value_wo_version = optional(string)
        name             = optional(string)
        tags             = optional(map(string))
        content_type     = optional(string)
        expiration_date  = optional(string)
        not_before_date  = optional(string)
      })))
      random_string = optional(map(object({
        name             = optional(string)
        length           = number
        numeric          = optional(bool)
        lower            = optional(bool)
        upper            = optional(bool)
        special          = optional(bool)
        min_lower        = optional(number)
        min_upper        = optional(number)
        min_special      = optional(number)
        min_numeric      = optional(number)
        override_special = optional(string)
        keepers          = optional(map(string))
        tags             = optional(map(string))
        content_type     = optional(string)
        expiration_date  = optional(string)
        not_before_date  = optional(string)
      })))
      tls_keys = optional(map(object({
        name            = optional(string)
        algorithm       = string
        rsa_bits        = optional(number)
        ecdsa_curve     = optional(string)
        tags            = optional(map(string))
        content_type    = optional(string)
        expiration_date = optional(string)
        not_before_date = optional(string)
      })))
    }))
    certs = optional(map(object({
      name = optional(string)
      tags = optional(map(string))
      certificate = optional(object({
        contents = string
        password = optional(string)
      }))
      issuer             = optional(string)
      key_type           = optional(string)
      key_size           = optional(number)
      reuse_key          = optional(bool)
      curve              = optional(string)
      content_type       = optional(string)
      subject            = string
      validity_in_months = number
      key_usage          = list(string)
      extended_key_usage = optional(list(string))
      subject_alternative_names = optional(object({
        dns_names = optional(list(string))
        upns      = optional(list(string))
        emails    = optional(list(string))
      }))
      lifetime_action = optional(object({
        action_type         = string
        days_before_expiry  = optional(number)
        lifetime_percentage = optional(number)
      }))
    })))
    access_policies = optional(map(object({
      object_id               = optional(string)
      tenant_id               = optional(string)
      application_id          = optional(string)
      key_permissions         = optional(list(string))
      secret_permissions      = optional(list(string))
      certificate_permissions = optional(list(string))
      storage_permissions     = optional(list(string))
    })))
  })

  validation {
    condition     = lookup(var.vault, "location", null) != null || var.location != null
    error_message = "location must be set on var.vault.location or on the module-level var.location."
  }

  validation {
    condition     = lookup(var.vault, "resource_group_name", null) != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.vault.resource_group_name or on the module-level var.resource_group_name."
  }
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

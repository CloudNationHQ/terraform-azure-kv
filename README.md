# Keyvault

 This terraform module simplifies the creation and management of azure key vault resources, providing customizable options for access policies, key and secret management, and auditing, all managed through code.

## Features

Capability to handle keys, secrets, and certificates.

Includes support for certificate issuers.

Utilization of terratest for robust validation.

Supports key rotation policy for enhanced security and compliance.

Integrates seamlessly with private endpoint capabilities for direct and secure connectivity.

## Private Endpoint

This module embeds private endpoint support directly (`vault.private_endpoints`). Embedding is the right choice when the Key Vault and its data-plane children (secrets, keys, certificates) are managed in the same Terraform apply with public network access disabled — Terraform has no network path to the vault's data plane without the PE in place during the same run.

When the PE belongs to a different state file or team (e.g. a platform networking team owns connectivity), use our standalone [terraform-azure-pe](https://github.com/CloudNationHQ/terraform-azure-pe) module instead and keep the vault publicly accessible or accept a two-phase apply. Both patterns are supported and the choice belongs to the caller.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

- <a name="requirement_tls"></a> [tls](#requirement\_tls) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (4.69.0)

- <a name="provider_random"></a> [random](#provider\_random) (3.8.1)

- <a name="provider_tls"></a> [tls](#provider\_tls) (4.2.1)

## Resources

The following resources are used by this module:

- [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_key_vault_access_policy.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_key_vault_certificate.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) (resource)
- [azurerm_key_vault_certificate_contacts.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate_contacts) (resource)
- [azurerm_key_vault_certificate_issuer.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate_issuer) (resource)
- [azurerm_key_vault_key.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_key_vault_secret.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_key_vault_secret.tls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_role_assignment.admins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [tls_private_key.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_vault"></a> [vault](#input\_vault)

Description: describes key vault related configuration

Type:

```hcl
object({
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
      name                            = optional(string)
      subnet_resource_id              = string
      subresource_name                = optional(string)
      private_dns_zone_resource_ids   = optional(list(string))
      application_security_group_ids  = optional(list(string))
      custom_network_interface_name   = optional(string)
      tags                            = optional(map(string))
      private_service_connection_name = optional(string)
      is_manual_connection            = optional(bool)
      request_message                 = optional(string)
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_certs"></a> [certs](#output\_certs)

Description: contains all certificates

### <a name="output_keys"></a> [keys](#output\_keys)

Description: contains all keys

### <a name="output_policies"></a> [policies](#output\_policies)

Description: contains all key vault access policies

### <a name="output_secrets"></a> [secrets](#output\_secrets)

Description: contains all secrets

### <a name="output_tls_private_keys"></a> [tls\_private\_keys](#output\_tls\_private\_keys)

Description: contains all tls private keys

### <a name="output_tls_public_keys"></a> [tls\_public\_keys](#output\_tls\_public\_keys)

Description: contains all tls public keys

### <a name="output_vault"></a> [vault](#output\_vault)

Description: contains all key vault config
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-kv/graphs/contributors).

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-kv/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-kv" />
</a>

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/terraform-azure-kv/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/keyvault/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/1f449b5a17448f05ce1cd914f8ed75a0b568d130/specification/keyvault)

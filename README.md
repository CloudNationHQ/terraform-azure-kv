# Keyvault

 This terraform module simplifies the creation and management of azure key vault resources, providing customizable options for access policies, key and secret management, and auditing, all managed through code.

## Features

- capability to handle keys, secrets, and certificates.
- includes support for certificate issuers.
- utilization of terratest for robust validation.
- supports key rotation policy for enhanced security and compliance.
- integrates seamlessly with private endpoint capabilities for direct and secure connectivity.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

- <a name="requirement_tls"></a> [tls](#requirement\_tls) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

- <a name="provider_random"></a> [random](#provider\_random) (~> 3.6)

- <a name="provider_tls"></a> [tls](#provider\_tls) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_key_vault.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_key_vault_access_policy.policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_key_vault_certificate.cert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate) (resource)
- [azurerm_key_vault_certificate_contacts.contact](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate_contacts) (resource)
- [azurerm_key_vault_certificate_issuer.issuer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_certificate_issuer) (resource)
- [azurerm_key_vault_key.kv_keys](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) (resource)
- [azurerm_key_vault_secret.secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_key_vault_secret.tls_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) (resource)
- [azurerm_role_assignment.admins](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_password.password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
- [tls_private_key.tls_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_vault"></a> [vault](#input\_vault)

Description: describes key vault related configuration

Type:

```hcl
object({
    name                            = string
    location                        = optional(string, null)
    resource_group_name             = optional(string, null)
    enable_rbac_authorization       = optional(bool, true)
    tenant_id                       = optional(string)
    sku_name                        = optional(string, "standard")
    tags                            = optional(map(string))
    enabled_for_deployment          = optional(bool, true)
    enabled_for_disk_encryption     = optional(bool, true)
    enabled_for_template_deployment = optional(bool, true)
    purge_protection_enabled        = optional(bool, true)
    public_network_access_enabled   = optional(bool, true)
    soft_delete_retention_days      = optional(number, 90)
    network_acls = optional(object({
      bypass                     = optional(string, "AzureServices")
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }), null)
    admins = optional(list(string))
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
        name            = optional(string)
        length          = number
        special         = optional(bool, true)
        min_lower       = optional(number, 5)
        min_upper       = optional(number, 7)
        min_special     = optional(number, 4)
        min_numeric     = optional(number, 5)
        tags            = optional(map(string))
        content_type    = optional(string, null)
        expiration_date = optional(string, null)
        not_before_date = optional(string, null)
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type:

```hcl
object({
    key_vault_key         = optional(string)
    key_vault_secret      = optional(string)
    key_vault_certificate = optional(string)
  })
```

Default: `{}`

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

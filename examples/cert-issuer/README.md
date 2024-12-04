# Cert Issuer

This deploys certificate issuers

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string

  issuers = optional(map(object({
    provider_name = optional(string)
    org_id        = optional(string)
    account_id    = optional(string)
    password      = optional(string)
  })))
})
```

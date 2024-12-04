# Certs

This deploys certificates

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string

  certs = optional(map(object({
    issuer             = optional(string)
    subject            = string
    validity_in_months = number
    key_type          = optional(string)
    key_size          = optional(string)
    reuse_key         = optional(bool)
    content_type      = optional(string)
    key_usage         = list(string)
    extended_key_usage = optional(list(string))

    lifetime_actions = optional(map(object({
      action_type        = string
      days_before_expiry = optional(number)
    })))

    subject_alternative_names = optional(object({
      dns_names = optional(list(string))
      emails    = optional(list(string))
      upns      = optional(list(string))
    }))
  })))
})
```

## Notes

Certificates can be self-signed, imported as PFX files, or issued by external certificate authorities like DigiCert and GlobalSign

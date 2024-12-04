# Secrets

This deploys vault secrets

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string

  secrets = optional(object({
    connection-string = optional(object({
      value = string
    }))
    random_string = optional(map(object({
      length  = number
      special = optional(bool)
    })))
    tls_keys = optional(map(object({
      algorithm = string
      rsa_bits  = optional(number)
    })))
  }))
})
```

## Notes

The vault supports defined secrets (like a primary storage key, as input from another module), random string secrets (generated strings), and TLS key pairs (generated public/private keys).

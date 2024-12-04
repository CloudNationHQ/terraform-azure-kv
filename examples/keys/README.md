# Keys

This deploys keys and rotation policies

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string

  keys = optional(map(object({
    key_type = string
    key_size = optional(number)
    key_opts = list(string)
    rotation_policy = optional(object({
      expire_after         = optional(string)
      notify_before_expiry = optional(string)
      automatic = optional(object({
        time_after_creation = optional(string)
      }))
    }))
  })))
})
```

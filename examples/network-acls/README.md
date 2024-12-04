# Network ACL's

This deploys network ACL's

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string

  public_network_access_enabled = optional(bool)
  network_acl = optional(object({
    virtual_network_subnet_ids = optional(list(string))
  }))
})
```

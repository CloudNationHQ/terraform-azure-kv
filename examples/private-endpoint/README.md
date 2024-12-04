# Private Endpoint

This deploys private endpoint

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string

  public_network_access_enabled = optional(bool)
})
```

# Notes

Private DNS zones and private endpoints are managed through separate modules when private networking is required

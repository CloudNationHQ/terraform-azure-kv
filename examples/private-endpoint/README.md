# Private Endpoint

This deploys private endpoint for keyvault

## Types

```hcl
vault = object({
  name           = string
  location       = string
  resource_group = string

  public_network_access_enabled = optional(bool)
})
```

## Notes

Additional modules will be used to configure private endpoints and private dns zones.

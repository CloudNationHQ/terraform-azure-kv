This example illustrates the default keyvault setup, in its simplest form.

## Usage: default

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.13"

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
  }
}
```

Additionally, for certain scenarios, the example below highlights the ability to use multiple key vaults, enabling a broader setup.

## Usage: multiple

```hcl
module "vaults" {
  source = "cloudnationhq/kv/azure"
  version = "~> 0.1"

  for_each = local.vaults

  vault = each.value
}
```

The module uses a local to iterate, generating a key vault for each key.


```hcl
locals {
  vaults = {
    kv1 = {
      name          = join("-", [module.naming.key_vault.name_unique, "001"])
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name
    },
    kv2 = {
      name          = join("-", [module.naming.key_vault.name_unique, "002"])
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name
    }
  }
}
```

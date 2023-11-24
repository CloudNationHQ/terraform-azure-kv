This example highlights how to specify a custom list of admins instead of the current identity.

## Usage

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.1"

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    admins                    = [var.admin_principal_id]
    current_identity_as_admin = false
  }
}
```

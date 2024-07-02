This example shows how to use network ACLs to enhance security with secure access control.

## Usage:

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.12"

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    public_access = false

    network_acl = {
      virtual_network_subnet_ids = [module.network.subnets.sn1.id]
    }
  }
}
```

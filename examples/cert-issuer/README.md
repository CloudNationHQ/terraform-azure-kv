This example highlights how to integrate a certificate issuer.

## Usage

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.7"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    issuers = {
      DigiCert = { org_id = "12345", account_id = "12345", password = "12345" }
    }
  }
}
```

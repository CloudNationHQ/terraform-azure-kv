This example outlines the approach for managing certificates to enhance security and automate the management of certificate lifecycles.

## Usage:

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.7"

  naming = local.naming

  vault = {
    demo = {
      name          = module.naming.key_vault.name_unique
      location      = module.rg.groups.demo.location
      resourcegroup = module.rg.groups.demo.name

      certs = {
        example = {
          issuer             = "Self"
          subject            = "CN=app1.demo.org"
          validity_in_months = 12
          exportable         = true
          key_usage = [
            "cRLSign", "dataEncipherment",
            "digitalSignature", "keyAgreement",
            "keyCertSign", "keyEncipherment"
          ]
        }
      }
    }
  }
}
```

This example highlights the streamlined creation and secure management of secrets.

## Usage

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.8"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    secrets = {
      random_string = {
        secret1 = {
          length  = 24
          special = false
        }
      }
      tls_keys = {
        tls1 = {
          algorithm = "RSA"
          rsa_bits  = 2048
        }
      }
    }
  }
}
```

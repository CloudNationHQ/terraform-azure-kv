This example highlights the streamlined creation and secure management of secrets. This can be either random generated secret strings (which fall under random_string key) or non-random secrets with the value passed on from another module or resource, e.g. a connection string of a storage account. 

## Usage

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.11"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    secrets = {
      connection-string = {
        value = module.storage.account.primary_connection_string
      }
      random_string = {
        secret1 = {
          length  = 24
          special = false
        }
      }
    }
  }
}
```

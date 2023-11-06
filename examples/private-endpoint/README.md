This example details a keyvault setup with a private endpoint, enhancing security by restricting data access to a private network.

## Usage: private endpoint

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.2"

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    private_endpoint = {
      name         = module.naming.private_endpoint.name
      dns_zones    = [module.private_dns.zone.id]
      subnet       = module.network.subnets.sn1.id
      subresources = ["vault"]
    }
  }
}
```

To enable private link, the below private dns submodule can be employed:

```hcl
module "private_dns" {
  source  = "cloudnationhq/kv/azure//modules/private-dns"
  version = "~> 0.1"

  providers = {
    azurerm = azurerm.connectivity
  }

  zone = {
    name          = "privatelink.vaultcore.azure.net"
    resourcegroup = "rg-dns-shared-001"
    vnet          = module.network.vnet.id
  }
}
```

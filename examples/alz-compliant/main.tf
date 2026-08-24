module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.25"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"

  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        network_security_group = {}
        address_prefixes       = ["10.19.1.0/24"]
      }
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 6.0"

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    sku_name                      = "standard"
    rbac_authorization_enabled    = true
    public_network_access_enabled = false
    purge_protection_enabled      = true
    soft_delete_retention_days    = 90
    enable_role_assignment        = true

    network_acls = {
      default_action = "Deny"
      bypass         = "AzureServices"
    }

    private_endpoints = {
      default = {
        name                            = module.naming.private_endpoint.name
        subnet_resource_id              = module.network.subnets.sn1.id
        private_dns_zone_resource_ids   = [module.private_dns.private_zones.vault.id]
        private_service_connection_name = "kv"
        subresource_name                = "vault"
      }
    }

    secrets = {
      random_string = {
        secret1 = {
          length          = 24
          special         = true
          expiration_date = "2030-01-01T00:00:00Z"
          content_type    = "text/plain"
        }
      }
    }

    keys = {
      key1 = {
        key_type = "RSA"
        key_size = 2048

        key_opts = [
          "decrypt", "encrypt",
          "sign", "unwrapKey",
          "verify", "wrapKey"
        ]

        rotation_policy = {
          expire_after         = "P90D"
          notify_before_expiry = "P14D"
          automatic = {
            time_before_expiry = "P30D"
          }
        }
      }
    }
  }
}

module "private_dns" {
  source  = "cloudnationhq/pdns/azure"
  version = "~> 5.0"

  resource_group_name = module.rg.groups.demo.name

  zones = {
    private = {
      vault = {
        name = "privatelink.vaultcore.azure.net"
        virtual_network_links = {
          link1 = {
            virtual_network_id   = module.network.vnet.id
            registration_enabled = true
          }
        }
      }
    }
  }
}

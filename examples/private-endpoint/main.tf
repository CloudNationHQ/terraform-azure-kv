module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.25"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 9.0"

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
  version = "~> 5.0"

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    public_network_access_enabled = false

    private_endpoints = {
      default = {
        name                            = module.naming.private_endpoint.name
        subnet_resource_id              = module.network.subnets.sn1.id
        private_dns_zone_resource_ids   = [module.private_dns.private_zones.vault.id]
        private_service_connection_name = "kv"
        subresource_name                = "vault"
      }
    }
  }
}

module "private_dns" {
  source  = "cloudnationhq/pdns/azure"
  version = "~> 4.0"

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

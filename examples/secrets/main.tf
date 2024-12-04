module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

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

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 2.0"

  storage = {
    name           = module.naming.storage_account.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name
  }
}

module "kv" {
  source = "../../"
  #source  = "cloudnationhq/kv/azure"
  #version = "~> 2.0"


  naming = local.naming

  vault = {
    name           = module.naming.key_vault.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

    secrets = {
      connection-string = {
        value = module.storage.account.primary_connection_string
      }
      random_string = {
        example = {
          length  = 24
          special = false
        }
      }
      tls_keys = {
        example = {
          algorithm = "RSA"
          rsa_bits  = 2048
        }
      }
    }
  }
}

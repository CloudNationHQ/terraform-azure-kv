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

## No admins
module "kv_1" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  vault = {
    admins              = []
    name                = "${module.naming.key_vault.name_unique}1"
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

## Multiple admins
module "kv_2" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  vault = {
    admins              = ["defc3bd7-5e15-4109-9800-92a80628c34d", "aabc3bd7-5e15-4109-9800-92a80628c34e"] ## IDs are fictional
    name                = "${module.naming.key_vault.name_unique}2"
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

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
module "kv1" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  vault = {
    enable_role_assignment = false
    name                   = "${module.naming.key_vault.name_unique}1"
    location               = module.rg.groups.demo.location
    resource_group_name    = module.rg.groups.demo.name
  }
}

## Multiple admins
module "kv2" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  vault = {
    admins              = ["12345678-5e15-4109-9800-109876543210", "12345678-2f4f-4afa-9259-109876543210"] ## IDs are fictional
    name                = "${module.naming.key_vault.name_unique}2"
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

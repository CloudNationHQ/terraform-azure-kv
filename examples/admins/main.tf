data "azurerm_client_config" "current" {}

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
    admins              = [data.azurerm_client_config.current.object_id]
    name                = "${module.naming.key_vault.name_unique}2"
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
  }
}

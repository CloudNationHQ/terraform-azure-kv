module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

data "azurerm_client_config" "current" {}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.1"
  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    admins                    = [data.azurerm_client_config.current.object_id]
    current_identity_as_admin = false
  }
}

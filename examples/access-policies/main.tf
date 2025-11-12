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

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  vault = {
    name                      = module.naming.key_vault.name_unique
    location                  = module.rg.groups.demo.location
    resource_group_name       = module.rg.groups.demo.name
    enable_rbac_authorization = false

    access_policies = {
      policy_current = {
        object_id = data.azurerm_client_config.current.object_id
        key_permissions = [
          "all"
        ]
        secret_permissions = [
          "all"
        ]
        certificate_permissions = [
          "all"
        ]
        storage_permissions = [
          "all"
        ]
      }
    }
  }
}

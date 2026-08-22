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

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 6.0"

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    secrets = {
      predefined_string = {
        sendgrid_api_key = {
          value_wo         = "SG.placeholder-sendgrid-api-key"
          value_wo_version = "1"
          content_type     = "text/plain"
        }
        stripe_secret_key = {
          value_wo         = "sk_live_placeholder-stripe-secret-key"
          value_wo_version = "1"
          content_type     = "text/plain"
        }
        db_password = {
          value_wo         = "placeholder-database-password"
          value_wo_version = "1"
          content_type     = "text/plain"
        }
      }
    }
  }
}

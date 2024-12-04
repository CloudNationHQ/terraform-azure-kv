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

module "kv" {
  #source  = "cloudnationhq/kv/azure"
  #version = "~> 2.0"
  source = "../../"

  naming = local.naming

  vault = {
    name           = module.naming.key_vault.name_unique
    location       = module.rg.groups.demo.location
    resource_group = module.rg.groups.demo.name

    certs = {
      example = {
        issuer             = "Self"
        subject            = "CN=app1.demo.org"
        validity_in_months = 12
        exportable         = true
        key_usage = [
          "cRLSign", "dataEncipherment",
          "digitalSignature", "keyAgreement",
          "keyCertSign", "keyEncipherment"
        ]
      }
    }
  }
}

#module "kv" {
  #source = "../../"

  #naming = local.naming

  #vault = {
    #name           = module.naming.key_vault.name_unique
    #location       = module.rg.groups.demo.location
    #resource_group = module.rg.groups.demo.name

    #certs = {
      #app1 = {
        #issuer             = "Self"
        #subject            = "CN=app1.demo.org"
        #validity_in_months = 12
        #key_type           = "RSA"
        #key_size           = "2048"
        #reuse_key          = false
        #content_type       = "application/x-pkcs12"
        #key_usage = [
          #"cRLSign",
          #"dataEncipherment",
          #"digitalSignature",
          #"keyAgreement",
          #"keyCertSign",
          #"keyEncipherment"
        #]
        #extended_key_usage = [
          #"1.3.6.1.5.5.7.3.1",
          #"1.3.6.1.5.5.7.3.2"
        #]
        #lifetime_actions = {
          #action1 = {
            #action_type        = "AutoRenew"
            #days_before_expiry = 30
          #}
        #}
        #subject_alternative_names = {
          #dns_names = ["app1.demo.org", "app1-dev.demo.org"]
          #emails    = ["admin@demo.org"]
          #upns      = ["user@demo.org"]
        #}
      #}
    #}
  #}
#}

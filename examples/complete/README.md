This example highlights the complete usage.

## Usage

```hcl
module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.13"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    certs   = local.certs
    keys    = local.keys
    secrets = local.secrets

    issuers = {
      DigiCert = {
        org_id     = "12345"
        account_id = "12345"
        password   = "12345"
      }
    }
  }
}
```

The module uses the below locals for configuration:

```hcl
locals {
  secrets = {
    random_string = {
      secret1 = {
        length  = 24
        special = false
      }
    }
    tls_keys = {
      tls1 = {
        algorithm = "RSA"
        rsa_bits  = 2048
      }
    }
  }

  keys = {
    key1 = {
      key_type = "RSA"
      key_size = 2048
      key_opts = [
        "decrypt", "encrypt", "sign",
        "unwrapKey", "verify", "wrapKey"
      ]
      rotation_policy = {
        expire_after         = "P90D"
        notify_before_expiry = "P30D"
        automatic = {
          time_after_creation = "P83D"
          time_before_expiry  = "P30D"
        }
      }
    }
  }

  certs = {
    cert1 = {
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
```

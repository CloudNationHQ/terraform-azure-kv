locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["key_vault_key", "key_vault_secret", "key_vault_certificate"]
}

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

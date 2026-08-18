mock_provider "azurerm" {
  mock_data "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-kv/providers/Microsoft.KeyVault/vaults/kv-existing"
    }
  }

  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id = "00000000-0000-0000-0000-000000000000"
      object_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  location            = "westeurope"
  resource_group_name = "rg-fallback"
}

run "existing_vault_is_looked_up" {
  command = plan

  variables {
    vault = {
      name                = "kv-app"
      resource_group_name = "rg-kv"
      use_existing        = true
      admins              = ["11111111-1111-1111-1111-111111111111"]
    }
  }

  assert {
    condition = length(data.azurerm_key_vault.this) == 1 && length(azurerm_key_vault.this) == 0
    error_message = format(
      "use_existing = true must select the data source, got %d data source instance(s) and %d managed vault(s)",
      length(data.azurerm_key_vault.this),
      length(azurerm_key_vault.this),
    )
  }

  assert {
    condition = data.azurerm_key_vault.this["this"].resource_group_name == "rg-kv"
    error_message = format(
      "existing vault must be looked up in vault.resource_group_name (\"rg-kv\"), got %q - %s",
      data.azurerm_key_vault.this["this"].resource_group_name,
      data.azurerm_key_vault.this["this"].resource_group_name == "rg-fallback" ? "the coalesce fell through to var.resource_group_name" : "unexpected resource group",
    )
  }

  assert {
    condition = azurerm_role_assignment.admins["0"].scope == data.azurerm_key_vault.this["this"].id
    error_message = format(
      "admin role assignment on an existing vault must scope to the data source id, got %q",
      azurerm_role_assignment.admins["0"].scope,
    )
  }

  assert {
    condition = output.vault.id == data.azurerm_key_vault.this["this"].id
    error_message = format(
      "output \"vault\" must expose the existing vault id, got %q",
      output.vault.id,
    )
  }
}

run "managed_vault_when_flag_unset" {
  command = apply

  override_resource {
    target = azurerm_key_vault.this["this"]
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-kv/providers/Microsoft.KeyVault/vaults/kv-managed"
    }
  }

  variables {
    vault = {
      name                = "kv-app"
      resource_group_name = "rg-kv"
      admins              = ["11111111-1111-1111-1111-111111111111"]
    }
  }

  assert {
    condition = length(data.azurerm_key_vault.this) == 0 && length(azurerm_key_vault.this) == 1
    error_message = format(
      "with use_existing unset the vault must be created and nothing looked up, got %d data source instance(s) and %d managed vault(s)",
      length(data.azurerm_key_vault.this),
      length(azurerm_key_vault.this),
    )
  }

  assert {
    condition = azurerm_role_assignment.admins["0"].scope == azurerm_key_vault.this["this"].id
    error_message = format(
      "admin role assignment on a created vault must scope to the managed resource id, got %q",
      azurerm_role_assignment.admins["0"].scope,
    )
  }

  assert {
    condition = output.vault.id == azurerm_key_vault.this["this"].id
    error_message = format(
      "output \"vault\" must expose the created vault id, got %q",
      output.vault.id,
    )
  }
}

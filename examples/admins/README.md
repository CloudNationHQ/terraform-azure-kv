# Admins
By default, the module assigns the `Key Vault Administrator` role to the service principal running Terraform.
This is done using `data.azurerm_client_config.current.object_id`, which ensures Terraform has the necessary access to manage Key Vault child resources such as secrets, keys, and certificates.

You can customize this behavior using the following options:

To set one or more custom admins:
```
admins = ["defc3bd7-5e15-4109-9800-92a80628c34d", "aabc3bd7-5e15-4109-9800-92a80628c34e"]
```

To prevent any admin role from being assigned:
```
enable_role_assignment = false
```

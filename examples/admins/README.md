# Admins

By default the module sets the `Key Vault Administrator` role to the service principal running the module.
This is done with `data.azurerm_client_config.current.object_id` and ensures that Terraform can still reach the Key Vault child resources like secrets, keys and/or certificates.
If desired, this behaviour can be overriden with the `admins` property. 

To set one or more (other) admins:
```
admin = ["defc3bd7-5e15-4109-9800-92a80628c34d", "aabc3bd7-5e15-4109-9800-92a80628c34e"]
```

To prevent the RBAC admin role from being set:
```
admin = []
```

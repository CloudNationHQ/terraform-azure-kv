# Network ACL's

This example sets network ACL's (firewall) to `Deny` (default) while still allowing a specific subnet.

## Note
In addition, public IP's with `ip_rules` can be whitelisted and / or set to `Allow Azure Services` with the `bypass` property.
The `public_network_access_enabled` must be used together, to ensure no public connectivity to the key vault can take place. 

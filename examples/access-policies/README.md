# Default

This example illustrates the use of access policies instead of RBAC. 

## Note

RBAC is the preferred method for data plane access control, however you might still have existing 
Key Vaults using access policies or some resources that do not support RBAC yet (like app service certificate).

By providing the value ``["all"]`` the module will lookup all the permissions so that you do not have to specify them all. 
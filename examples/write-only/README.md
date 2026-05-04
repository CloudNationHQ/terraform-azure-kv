# Write-only Secrets

This example demonstrates storing third-party credentials in Key Vault using the `value_wo` attribute. The secret value is written to Key Vault but never read back or stored in Terraform state.

## Notes

In practice, `value_wo` values come from vendor portals (Stripe, SendGrid, etc.) and are injected at apply time via `TF_VAR_*` environment variables in the pipeline — never hardcoded in the configuration.

To rotate a secret, obtain the new key from the vendor, update the value, and increment `value_wo_version`. Terraform will re-write the secret without reading the current value from Key Vault.

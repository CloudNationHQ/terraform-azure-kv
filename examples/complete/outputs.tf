output "vault" {
  value     = module.kv.vault
  sensitive = true
}

output "subscription_id" {
  value = module.kv.subscription_id
}

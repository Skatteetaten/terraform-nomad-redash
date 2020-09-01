module "redash" {
  source = "../../"

  redash_admin_username ="admin"
  redash_admin_password = "admin123"
  redash_admin_email_id  = "admin@mail.com"
}

output "redash_username"{
  description = "Redash admin username"
  value= module.redash.redash_admin_username
}

output "redash_password" {
  description = "Redash admin password"
  value       = module.redash.redash_admin_password
}

output "redash_email_id" {
  description = "Redash admin email id"
  value       = module.redash.redash_admin_email_id
}

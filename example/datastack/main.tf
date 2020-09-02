module "redash" {
  source = "../../"
  # postgres
  postgres_service_name   = module.postgres.service_name
  postgres_container_port = module.postgres.port
  postgres_username       = module.postgres.username
  postgres_password       = module.postgres.password
  redash_admin_username   = "admin"
  redash_admin_password   = "admin123"
  redash_admin_email_id   = "admin@mail.com"
  # presto
  presto_service_name     = module.presto.presto_service_name
  presto_container_port   = module.presto.presto_port

  depends_on = [
    module.presto
  ]
}

output "redash_username"{
  description = "Redash admin username"
  value       = module.redash.redash_admin_username
}

output "redash_password" {
  description = "Redash admin password"
  value       = module.redash.redash_admin_password
}

output "redash_email_id" {
  description = "Redash admin email id"
  value       = module.redash.redash_admin_email_id
}
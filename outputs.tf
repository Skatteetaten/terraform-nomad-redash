output "postgres_service_name" {
  description = "Postgres service name"
  value = var.postgres_service_name
}

output "postgres_port" {
  description = "Postgres container port"
  value = var.postgres_port
}

output "postgres_image" {
  description = "Postgres container image"
  value = var.postgres_image
}

output "postgres_database_name" {
  description = "Postgres database name"
  value = var.postgres_database_name
}

output "postgres_username" {
  description = "Postgres username"
  value = var.postgres_username
}

output "postgres_password" {
  description = "Postgres password"
  value = var.postgres_password
}
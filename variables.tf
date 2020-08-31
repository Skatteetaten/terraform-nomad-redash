# Nomad
variable "nomad_provider_address" {
  type        = string
  description = "Nomad address"
  default     = "http://127.0.0.1:4646"
}
variable "nomad_datacenters" {
  type        = list(string)
  description = "Nomad data centers"
  default     = ["dc1"]
}
variable "nomad_namespace" {
  type        = string
  description = "[Enterprise] Nomad namespace"
  default     = "default"
}

# Email
variable "email_container_image" {
  type = string
  description = "Email container image"
  default = "djfarrelly/maildev:1.1.0"
}

# Postgres
variable "postgres_container_image" {
  type = string
  description = "Postgres container image"
  default = "postgres:9.5-alpine"
}

# Redis
variable "redis_container_image" {
  type = string
  description = "Redis container image"
  default = "redis:3-alpine"
}

# Redash
variable "redash_container_image" {
  type = string
  description = "Redash container image"
  default = "redash/redash:8.0.2.b37747"
}
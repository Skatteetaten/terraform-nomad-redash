variable "postgres_service_name" {
  type = string
  description = "Postgres service name"
  default = "postgres"
}

variable "postgres_port" {
  type = number
  description = "Postgres container port"
  default = 5432
}

variable "postgres_username" {
  type = string
  description = "Postgres username"
  default = "redash"
}

variable "postgres_password" {
  type = string
  description = "Postgres password"
  default = "redash"
}

variable "redash_admin_username" {
  type        = string
  description = "Redash admin username"
  default     = "admin"
}

variable "redash_admin_password" {
  type        = string
  description = "Redash admin password"
  default     = "admin123"
}

variable "redash_admin_email_id" {
  type        = string
  description = "Redash admin email id"
  default     = "admin@mail.com"
}
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
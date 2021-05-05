## Nomad
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
# Redash
variable "service" {
  type        = string
  description = "Redash service name"
  default     = "redash"
}
variable "host" {
  type        = string
  description = "Redash host"
  default     = "127.0.0.1"
}
variable "port" {
  type        = number
  description = "Redash port"
  default     = 5000
}
variable "container_image" {
  type        = string
  description = "Redash docker image"
  default     = "redash/redash:9.0.0-beta.b42121"
}
variable "resource" {
  type = object({
    cpu    = number,
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 1024
  }
  description = "Redash resources. CPU and memory allocation."
  validation {
    condition     = var.resource.cpu >= 200 && var.resource.memory >= 1024
    error_message = "Redash resource must be at least: cpu=500, memory=1024."
  }
}
variable "resource_proxy" {
  type = object({
    cpu    = number,
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 128
  }
  description = "Redash proxy resources"
  validation {
    condition     = var.resource_proxy.cpu >= 200 && var.resource_proxy.memory >= 128
    error_message = "Proxy resource must be at least: cpu=200, memory=128."
  }
}

variable "use_canary" {
  type        = bool
  description = "Uses canary deployment for Redash"
  default     = false
}

# Redis
variable "redis_service" {
  type = object({
    service = string,
    port    = number,
    host    = string
  })
  default = {
    service = "redis",
    port    = 6379
    host    = "127.0.0.1"
  }
  description = "Redis data-object contains service, port and host"
}

# Postgres
variable "postgres_service" {
  type = object({
    service = string,
    port    = number,
    host    = string
  })
  default = {
    service = "postgres",
    port    = 5432
    host    = "127.0.0.1"
  }
  description = "Postgres data-object contains service, port and host"
}
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
variable "service_name" {
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
  default     = "redash/redash:preview"
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

variable "redash_config_properties" {
  type        = list(string)
  description = "Custom redash configuration properties"
  default = ["python /app/manage.py database create_tables",
    "python /app/manage.py users create_root admin@mail.com admin123 --password admin --org default",
  "/usr/local/bin/gunicorn -b 0.0.0.0:5000 --name redash -w4 redash.wsgi:app --max-requests 1000 --max-requests-jitter 100"]
}


# Redis
variable "redis_service" {
  type = object({
    service_name = string,
    port         = number,
  })
  default = {
    service_name = "redash-redis",
    port         = 6379
  }
  description = "Redis data-object contains service_name and port."
}

# Postgres
variable "postgres_service" {
  type = object({
    service_name = string,
    port         = number,
  })
  default = {
    service_name = "redash-postgres",
    port         = 5432
  }
  description = "Postgres data-object contains service and port."
}

# Datasources
variable "datasource_upstreams" {
  type = list(object({
    service_name = string,
    port         = number,
  }))
  description = "List of upstream services (list of object with service_name, port)"
  default     = []
}

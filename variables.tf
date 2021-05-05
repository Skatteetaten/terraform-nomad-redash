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
  default     = "Redash"
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

//# Email
//variable "email_service_name" {
//  type        = string
//  description = "Email service name"
//  default     = "redash-email-service"
//}
//
//variable "email_container_port" {
//  type        = number
//  description = "Email container port"
//  default     = 80
//}
//
//variable "email_container_image" {
//  type        = string
//  description = "Email container image"
//  default     = "djfarrelly/maildev:1.1.0"
//}
//
//variable "email_count" {
//  type        = number
//  description = "Email count"
//  default     = 1
//}
//
//# Presto
//variable "presto_service_name" {
//  type        = string
//  description = "Presto service name"
//  default     = "presto"
//}
//
//variable "presto_container_port" {
//  type        = number
//  description = "Presto container port"
//  default     = 8080
//}
//
//# Redis
//variable "redis_service_name" {
//  type        = string
//  description = "Redis service name"
//  default     = "redash-redis-service"
//}
//
//variable "redis_container_port" {
//  type        = number
//  description = "Redis container port"
//  default     = 6379
//}
//
//variable "redis_container_image" {
//  type        = string
//  description = "Redis container image"
//  default     = "redis:3-alpine"
//}
//
//variable "redis_count" {
//  type        = number
//  description = "Redis count"
//  default     = 1
//}
//
//# Postgres
//variable "postgres_service_name" {
//  type        = string
//  description = "Postgres service name"
//  default     = "postgres"
//}
//
//variable "postgres_container_port" {
//  type        = number
//  description = "Postgres container port"
//  default     = 5432
//}
//
//variable "postgres_container_image" {
//  type        = string
//  description = "Postgres container image"
//  default     = "postgres:9.5-alpine"
//}
//
//variable "postgres_username" {
//  type        = string
//  description = "Postgres username"
//  default     = "redash"
//}
//
//variable "postgres_password" {
//  type        = string
//  description = "Postgres password"
//  default     = "redash"
//}
//
//# Redash
//variable "redash_server_service_name" {
//  type        = string
//  description = "Redash server service name"
//  default     = "redash-server-service"
//}
//
//variable "redash_server_count" {
//  type        = number
//  description = "Redash server count"
//  default     = 1
//}
//
//variable "redash_worker_service_name" {
//  type        = string
//  description = "Redash worker service name"
//  default     = "redash-worker-service"
//}
//
//variable "redash_worker_count" {
//  type        = number
//  description = "Redash worker count"
//  default     = 1
//}
//
//variable "redash_scheduler_service_name" {
//  type        = string
//  description = "Redash scheduler service name"
//  default     = "redash-scheduler-service"
//}
//
//variable "redash_scheduler_count" {
//  type        = number
//  description = "Redash server count"
//  default     = 1
//}
//
//variable "redash_container_port" {
//  type        = number
//  description = "Redash container port"
//  default     = 5000
//}
//
//variable "redash_container_image" {
//  type        = string
//  description = "Redash container image"
//  default     = "redash/redash:8.0.2.b37747"
//}
//
//variable "redash_mail_port" {
//  type        = number
//  description = "Redash email port"
//  default     = 25
//}
//
//variable "redash_admin_username" {
//  type        = string
//  description = "Redash admin username"
//  default     = "admin"
//}
//
//variable "redash_admin_password" {
//  type        = string
//  description = "Redash admin password"
//  default     = "admin123"
//}
//
//variable "redash_admin_email_id" {
//  type        = string
//  description = "Redash admin email id"
//  default     = "admin@mail.com"
//}
//
//variable "redash_resource_cpu" {
//  type        = number
//  description = "Redash cpu resource"
//  default     = 500
//}
//
//variable "redash_resource_memory" {
//  type        = number
//  description = "Redash mamory resource"
//  default     = 1028
//}
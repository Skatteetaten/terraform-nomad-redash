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
  default     = []
  //  default = ["python /app/manage.py database create_tables",
  //    "python /app/manage.py users create_root admin@mail.com admin123 --password admin --org default",
  //  "/usr/local/bin/gunicorn -b 0.0.0.0:5000 --name redash -w4 redash.wsgi:app --max-requests 1000 --max-requests-jitter 100"]
}

variable "container_environment_variables" {
  type        = list(string)
  description = "Redash environment variables"
  default     = [""]
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
    service_name  = string,
    port          = number,
    username      = string,
    password      = string,
    database_name = string
  })
  default = {
    service_name  = "redash-postgres",
    port          = 5432,
    username      = "username",
    password      = "password",
    database_name = "metastore"
  }
  description = "Postgres data-object contains service, port, username, password and database_name."
}
variable "postgres_vault_secret" {
  type = object({
    use_vault_provider      = bool,
    vault_kv_policy_name    = string,
    vault_kv_path           = string,
    vault_kv_field_username = string,
    vault_kv_field_password = string
  })
  description = "Set of properties to be able to fetch Postgres secrets from vault"
  default = {
    use_vault_provider      = false
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/data/dev/postgres"
    vault_kv_field_username = "username"
    vault_kv_field_password = "password"
  }
}

variable "ldap_vault_secret" {
  type = object({
    use_vault_provider      = bool,
    vault_kv_policy_name    = string,
    vault_kv_path           = string,
    vault_kv_field_username = string,
    vault_kv_field_password = string
  })
  description = "Set of properties to be able to fetch ldap secrets from Vault"
  default = {
    use_vault_provider      = false
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/data/dev/ldap"
    vault_kv_field_username = "username"
    vault_kv_field_password = "password"
  }
}

variable "redash_admin_vault_secret" {
  type = object({
    use_vault_provider      = bool,
    vault_kv_policy_name    = string,
    vault_kv_path           = string,
    vault_kv_field_username = string,
    vault_kv_field_password = string
  })
  description = "Set of properties to be able to fetch redash secrets from Vault"
  default = {
    use_vault_provider      = false
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/data/dev/redash"
    vault_kv_field_username = "admin_user"
    vault_kv_field_password = "admin_password"
  }
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


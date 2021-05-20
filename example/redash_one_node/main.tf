module "redash" {
  source = "../.."
  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # redash
  service_name    = "redash"
  host            = "127.0.0.1"
  port            = 5000
  container_image = "redash/redash:8.0.2.b37747"
  use_canary      = false

  redash_config_properties = ["python /app/manage.py database create_tables",
    "python /app/manage.py users create_root admin@mail.com admin123 --password admin --org default",
    "/usr/local/bin/gunicorn -b 0.0.0.0:5000 --name redash -w4 redash.wsgi:app --max-requests 1000 --max-requests-jitter 100"]

  postgres_service = {
    service_name  = module.redash-postgres.service_name
    port          = module.redash-postgres.port
    username      = module.redash-postgres.username
    password      = module.redash-postgres.password
    database_name = module.redash-postgres.database_name
  }
  postgres_vault_secret = {
    use_vault_provider      = true
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/dev/postgres"
    vault_kv_field_username = "username"
    vault_kv_field_password = "password"
  }
}


module "redash-redis" {
  source = "github.com/Skatteetaten/terraform-nomad-redis.git?ref=0.1.0"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # redis
  service_name    = "redash-redis"
  host            = "127.0.0.1"
  port            = 6379
  container_image = "redis:3-alpine"
  use_canary      = false
  resource_proxy = {
    cpu    = 200
    memory = 128
  }
}


module "redash-postgres" {
  source = "github.com/Skatteetaten/terraform-nomad-postgres.git?ref=0.4.1"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # postgres
  service_name    = "redash-postgres"
  container_image = "postgres:12-alpine"
  container_port  = 5432
  vault_secret = {
    use_vault_provider      = true,
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/dev/postgres"
    vault_kv_field_username = "username"
    vault_kv_field_password = "password"
  }
  admin_user                      = "username"
  admin_password                  = "password"
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = false
  use_canary                      = false
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data/"]
}


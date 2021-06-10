module "redash" {
  source = "../.."
  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # redash
  service_name    = "redash"
  host            = "127.0.0.1"
  port            = 5000
  container_image = "gitlab-container-registry.minerva.loc/datainn/redash-rabbit-edition:ptmin-1394-create-datasources"
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
  ldap_vault_secret = {
    use_vault_provider      = true
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/dev/ldap"
    vault_kv_field_username = "username"
    vault_kv_field_password = "password"
  }
  container_environment_variables = [
    "REDASH_LDAP_CUSTOM_USERNAME_PROMPT=Brukerid",
    "REDASH_LDAP_LOGIN_ENABLED=true",
    "REDASH_PASSWORD_LOGIN_ENABLED=true",
    "REDASH_LDAP_URL=ldaps://skead.no:636",
    "REDASH_LDAP_SEARCH_DN='DC=skead,DC=no'",
    "REDASH_LDAP_SEARCH_TEMPLATE=(&(objectClass=user)(sAMAccountName=%(username)s)(memberof=CN=APP_datainn_utv,OU=Prosjekter,OU=vRAutomation,OU=Produksjon,OU=Applikasjoner,OU=Grupper,DC=skead,DC=no))"
  ]

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


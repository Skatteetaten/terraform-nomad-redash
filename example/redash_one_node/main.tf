module "redash" {
  source = "../.."
  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # redash
  service         = "redash"
  host            = "127.0.0.1"
  port            = 5000
  container_image = "redash/redash:9.0.0-beta.b42121"
  use_canary      = false
  resource_proxy = {
    cpu    = 200
    memory = 128
  }
}


module "redis" {
  source = "github.com/Skatteetaten/terraform-nomad-redis.git?ref=0.1.0"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # redis
  service_name    = "redis"
  host            = "127.0.0.1"
  port            = 6379
  container_image = "redis:3-alpine"
  use_canary      = false
  resource_proxy = {
    cpu    = 200
    memory = 128
  }

}


module "postgres" {
  source = "github.com/Skatteetaten/terraform-nomad-postgres.git?ref=0.4.1"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  nomad_host_volume = "persistence"

  # postgres
  service_name    = "postgres"
  container_image = "postgres:12-alpine"
  container_port  = 5432
  vault_secret = {
    use_vault_provider      = false,
    vault_kv_policy_name    = "",
    vault_kv_path           = "",
    vault_kv_field_username = "",
    vault_kv_field_password = ""
  }
  admin_user                      = "postgres"
  admin_password                  = "postgres"
  database                        = "metastore"
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = false
  use_canary                      = false
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data/"]
}

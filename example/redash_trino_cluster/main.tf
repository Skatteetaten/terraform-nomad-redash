locals {
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  trino_datastore = jsonencode({
    catalog : "hive",
    host : "127.0.0.1",
    port : 8080,
    schema : "default",
    username : "trino"
  })
}

module "redash" {
  source = "../.."

  # redash
  service_name    = "redash"
  host            = "127.0.0.1"
  port            = 5000
  container_image = "gitlab-container-registry.minerva.loc/datainn/redash-rabbit-edition:latest"
  use_canary      = false

  # Customized redash configuration
  redash_config_properties = ["python /app/manage.py database create_tables",
    "python /app/manage.py users create_root admin@mail.com admin123 --password admin --org default",
    format("python /app/manage.py ds new \\\"trino\\\" --type \\\"trino\\\" --options '%s' --org default", trimsuffix(trimprefix(jsonencode(local.trino_datastore), "\""), "\"")),
  "/usr/local/bin/gunicorn -b 0.0.0.0:5000 --name redash -w4 redash.wsgi:app --max-requests 1000 --max-requests-jitter 100"]

  # Redash redis
  redis_service = {
    service_name = module.redash-redis.redis_service
    port         = module.redash-redis.redis_port
  }
  # Redash postgres
  postgres_service = {
    service_name = module.redash-postgres.service_name
    port         = module.redash-postgres.port
  }

  # Datasource upstream
  datasource_upstreams = [{ service_name = module.trino.trino_service_name, port = 8080 }]
}


module "redash-redis" {
  source = "github.com/Skatteetaten/terraform-nomad-redis.git?ref=0.1.0"

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

  # postgres
  service_name    = "redash-postgres"
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
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = false
  use_canary                      = false
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data/"]
}

module "trino" {
  source = "github.com/Skatteetaten/terraform-nomad-trino.git?ref=0.4.0"

  depends_on = [
    module.postgres,
    module.minio,
    module.hive
  ]

  # nomad
  nomad_job_name    = "trino"
  nomad_datacenters = local.nomad_datacenters
  nomad_namespace   = local.nomad_namespace

  # trino
  vault_secret = {
    use_vault_provider         = true
    vault_kv_policy_name       = "kv-secret"
    vault_kv_path              = "secret/data/dev/trino"
    vault_kv_field_secret_name = "cluster_shared_secret"
  }
  service_name     = "trino"
  mode             = "standalone"
  workers          = 1
  consul_http_addr = "http://10.0.3.10:8500"
  debug            = true
  use_canary       = true
  hive_config_properties = [
    "hive.allow-drop-table=true",
    "hive.allow-rename-table=true",
    "hive.allow-add-column=true",
    "hive.allow-drop-column=true",
    "hive.allow-rename-column=true",
  "hive.compression-codec=ZSTD"]

  resource = {
    cpu    = 500
    memory = 1024
  }

  resource_proxy = {
    cpu    = 200
    memory = 128
  }

  # other
  hivemetastore_service = {
    service_name = module.hive.service_name
    port         = module.hive.port
  }
  minio_service = {
    service_name = module.minio.minio_service_name
    port         = module.minio.minio_port
    access_key   = module.minio.minio_access_key
    secret_key   = module.minio.minio_secret_key
  }
  minio_vault_secret = {
    use_vault_provider         = false
    vault_kv_policy_name       = ""
    vault_kv_path              = ""
    vault_kv_field_access_name = ""
    vault_kv_field_secret_name = ""
  }
  postgres_service = {
    service_name  = module.postgres.service_name
    port          = module.postgres.port
    username      = module.postgres.username
    password      = module.postgres.password
    database_name = module.postgres.database_name
  }
  postgres_vault_secret = {
    use_vault_provider      = false
    vault_kv_policy_name    = ""
    vault_kv_path           = ""
    vault_kv_field_username = ""
    vault_kv_field_password = ""
  }
}

module "minio" {
  source = "github.com/skatteetaten/terraform-nomad-minio.git?ref=0.4.0"

  # nomad
  nomad_datacenters = local.nomad_datacenters
  nomad_namespace   = local.nomad_namespace
  nomad_host_volume = "persistence-minio"

  # minio
  service_name    = "minio"
  host            = "127.0.0.1"
  port            = 9000
  container_image = "minio/minio:latest" # todo: avoid using tag latest in future releases
  vault_secret = {
    use_vault_provider        = false,
    vault_kv_policy_name      = "",
    vault_kv_path             = "",
    vault_kv_field_access_key = "",
    vault_kv_field_secret_key = ""
  }
  access_key      = "minio"
  secret_key      = "minio123"
  buckets         = ["default", "hive"]
  data_dir        = "/minio/data"
  use_host_volume = false
  use_canary      = false

  # mc
  mc_service_name                    = "mc"
  mc_container_image                 = "minio/mc:latest" # todo: avoid using tag latest in future releases
  mc_container_environment_variables = ["JUST_EXAMPLE_VAR3=some-value", "ANOTHER_EXAMPLE4=some-other-value"]
}

module "postgres" {
  source = "github.com/skatteetaten/terraform-nomad-postgres.git?ref=0.4.1"

  # nomad
  nomad_datacenters = local.nomad_datacenters
  nomad_namespace   = local.nomad_namespace
  nomad_host_volume = "persistence-postgres"

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
  admin_user                      = "hive"
  admin_password                  = "hive"
  database                        = "metastore"
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data"]
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = false
  use_canary                      = false
}

module "hive" {
  source = "github.com/skatteetaten/terraform-nomad-hive.git?ref=0.4.0"

  # nomad
  nomad_datacenters  = local.nomad_datacenters
  nomad_namespace    = local.nomad_namespace
  local_docker_image = false

  # hive
  use_canary          = true
  hive_service_name   = "hive-metastore"
  hive_container_port = 9083
  hive_docker_image   = "fredrikhgrelland/hive:3.1.0"
  resource = {
    cpu    = 500,
    memory = 1024
  }
  resource_proxy = {
    cpu    = 200,
    memory = 128
  }

  #support CSV -> https://towardsdatascience.com/load-and-query-csv-file-in-s3-with-trino-b0d50bc773c9
  #metastore.storage.schema.reader.impl=org.apache.hadoop.hive.metastore.SerDeStorageSchemaReader
  hive_container_environment_variables = [
    "HIVE_SITE_CONF_metastore_storage_schema_reader_impl=org.apache.hadoop.hive.metastore.SerDeStorageSchemaReader"
  ]

  # hive - minio
  hive_bucket = {
    default = "default",
    hive    = "hive"
  }
  minio_service = {
    service_name = module.minio.minio_service_name,
    port         = module.minio.minio_port,
    access_key   = module.minio.minio_access_key,
    secret_key   = module.minio.minio_secret_key,
  }

  # hive - postgres
  postgres_service = {
    service_name  = module.postgres.service_name
    port          = module.postgres.port
    database_name = module.postgres.database_name
    username      = module.postgres.username
    password      = module.postgres.password
  }

  depends_on = [
    module.minio,
    module.postgres
  ]
}
module "redash" {
  source = "../../"
}

module "minio" {
  source = "github.com/fredrikhgrelland/terraform-nomad-minio.git?ref=0.0.2"
  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace = "default"
  # minio
  service_name = "minio"
  host = "127.0.0.1"
  port = 9000
  container_image = "minio/minio:latest" # todo: avoid using tag latest in future releases
  access_key = "minio"
  secret_key = "minio123"
  buckets = ["default", "hive"]
  container_environment_variables = ["JUST_EXAMPLE_VAR1=some-value", "ANOTHER_EXAMPLE2=some-other-value"]
  # mc
  mc_service_name = "mc"
  mc_container_image = "minio/mc:latest" # todo: avoid using tag latest in future releases
  mc_container_environment_variables = ["JUST_EXAMPLE_VAR3=some-value", "ANOTHER_EXAMPLE4=some-other-value"]
}

module "hive" {
  source = "github.com/fredrikhgrelland/terraform-nomad-hive.git?ref=0.0.1"
  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace = "default"
  nomad_job_switch_local = false
  # hive
  hive_service_name = "hive-metastore"
  hive_container_port = 9083
  hive_docker_image = "fredrikhgrelland/hive:3.1.0"
  hive_container_environment_variables = ["SOME_EXAMPLE=example-value"]
  # hive - minio
  hive_bucket = {
    default     = "default",
    hive        = "hive"
  }
  minio_service = {
    service_name = module.minio.minio_service_name,
    port         = 9000,  # todo: minio 0.0.1 does not have output variable port
    access_key   = module.minio.minio_access_key,
    secret_key   = module.minio.minio_secret_key,
  }
  # hive - postgres
  postgres_service = {
    service_name  = module.redash.postgres_service_name
    port          = module.redash.postgres_port
    database_name = module.redash.postgres_database_name
    username      = module.redash.postgres_username
    password      = module.redash.postgres_password
  }

  depends_on = [
    module.minio,
    module.redash
  ]
}

module "presto" {
  source = "github.com/fredrikhgrelland/terraform-nomad-presto.git?ref=0.0.1"
  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  nomad_job_name    = "presto"
  # presto
  service_name = "presto"
  port         = 8080
  docker_image = "prestosql/presto:333"
  #hivemetastore
  hivemetastore = {
    service_name = module.hive.service_name
    port         = 9083 # todo: add output var
  }
  # minio
  minio = {
    service_name = module.minio.minio_service_name
    port         = 9000 # todo: add output var
    access_key   = module.minio.minio_access_key
    secret_key   = module.minio.minio_secret_key
  }

  depends_on = [
    module.minio,
    module.hive
  ]
}
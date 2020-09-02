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
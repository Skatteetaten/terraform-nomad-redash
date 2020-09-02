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
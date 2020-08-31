module "postgres" {
  source = "github.com/fredrikhgrelland/terraform-nomad-postgres.git?ref=0.0.1"
  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace = "default"
  # postgres
  postgres_service_name     = var.postgres_service_name
  postgres_container_image  = var.postgres_image
  postgres_container_port   = var.postgres_port
  postgres_admin_user       = var.postgres_username
  postgres_admin_password   = var.postgres_password
  postgres_database         = var.postgres_database_name
  postgres_container_environment_variables = ["PGDATA=/var/lib/postgresql/data"]
}

data "template_file" "nomad_job_redash_server" {
  template = file("${path.module}/conf/nomad/redash_server.hcl")
  vars = {
    postgres_service_name = module.postgres.service_name
    postgres_user         = module.postgres.username
    postgres_password     = module.postgres.password
  }
}

data "template_file" "nomad_job_redash_worker" {
  template = file("${path.module}/conf/nomad/redash_worker.hcl")
  vars = {
    postgres_service_name = module.postgres.service_name
    postgres_user         = module.postgres.username
    postgres_password     = module.postgres.password
  }
}

data "template_file" "nomad_job_redash_scheduler" {
  template = file("${path.module}/conf/nomad/redash_scheduler.hcl")
  vars = {
    postgres_service_name = module.postgres.service_name
    postgres_user         = module.postgres.username
    postgres_password     = module.postgres.password
  }
}

data "template_file" "nomad_job_redis" {
  template = file("${path.module}/conf/nomad/redis.hcl")
}

data "template_file" "nomad_job_email" {
  template = file("${path.module}/conf/nomad/email.hcl")
}

resource "nomad_job" "nomad_job_redash_server" {
  jobspec = data.template_file.nomad_job_redash_server.rendered
  detach = false
  depends_on = [
    nomad_job.nomad_job_redis,
    nomad_job.nomad_job_email,
    module.postgres
  ]
}

resource "nomad_job" "nomad_job_redash_worker" {
  jobspec = data.template_file.nomad_job_redash_worker.rendered
  detach = false
  depends_on = [
    nomad_job.nomad_job_redash_server
  ]
}

resource "nomad_job" "nomad_job_redash_scheduler" {
  jobspec = data.template_file.nomad_job_redash_scheduler.rendered
  detach = false
  depends_on = [
    nomad_job.nomad_job_redash_server
  ]
}

resource "nomad_job" "nomad_job_redis" {
  jobspec = data.template_file.nomad_job_redis.rendered
  detach = false
}

resource "nomad_job" "nomad_job_email" {
  jobspec = data.template_file.nomad_job_email.rendered
  detach = false
}
locals {
  datacenters = join(",", var.nomad_datacenters)
}

data "template_file" "nomad_job_redash_server" {
  template = file("${path.module}/conf/nomad/redash_server.hcl")
  vars = {
    # nomad
    datacenters                = local.datacenters
    # redash
    redash_server_service_name = var.redash_server_service_name
    redash_image               = var.redash_container_image
    redash_port                = var.redash_container_port
    redash_mail_port           = var.redash_mail_port
    redash_admin_username      = var.redash_admin_username
    redash_admin_password      = var.redash_admin_password
    redash_admin_email_id      = var.redash_admin_email_id
    redash_cpu                 = var.redash_resource_cpu
    redash_memory              = var.redash_resource_memory
    redash_server_count        = var.redash_server_count
    # postgres
    postgres_service_name      = var.postgres_service_name
    postgres_port              = var.postgres_container_port
    postgres_username          = var.postgres_username
    postgres_password          = var.postgres_password
    # redis
    redis_service_name         = var.redis_service_name
    redis_port                 = var.redis_container_port
    # email
    email_service_name         = var.email_service_name
    email_port                 = var.email_container_port
    # presto
    presto_service_name        = var.presto_service_name
    presto_container_port      = var.presto_container_port
  }
}

data "template_file" "nomad_job_redash_worker" {
  template = file("${path.module}/conf/nomad/redash_worker.hcl")
  vars = {
    # nomad
    datacenters                = local.datacenters
    # redash
    redash_worker_service_name = var.redash_worker_service_name
    redash_image               = var.redash_container_image
    redash_port                = var.redash_container_port
    redash_mail_port           = var.redash_mail_port
    redash_cpu                 = var.redash_resource_cpu
    redash_memory              = var.redash_resource_memory
    redash_worker_count        = var.redash_worker_count
    # postgres
    postgres_service_name      = var.postgres_service_name
    postgres_port              = var.postgres_container_port
    postgres_username          = var.postgres_username
    postgres_password          = var.postgres_password
    # redis
    redis_service_name         = var.redis_service_name
    redis_port                 = var.redis_container_port
    # email
    email_service_name         = var.email_service_name
    email_port                 = var.email_container_port
    # presto
    presto_service_name        = var.presto_service_name
    presto_container_port      = var.presto_container_port
  }
}

data "template_file" "nomad_job_redash_scheduler" {
  template = file("${path.module}/conf/nomad/redash_scheduler.hcl")
  vars = {
    # nomad
    datacenters                   = local.datacenters
    # redash
    redash_scheduler_service_name = var.redash_scheduler_service_name
    redash_image                  = var.redash_container_image
    redash_mail_port              = var.redash_mail_port
    redash_cpu                    = var.redash_resource_cpu
    redash_memory                 = var.redash_resource_memory
    redash_scheduler_count        = var.redash_scheduler_count
    # postgres
    postgres_service_name         = var.postgres_service_name
    postgres_port                 = var.postgres_container_port
    # redis
    redis_service_name            = var.redis_service_name
    redis_port                    = var.redis_container_port
    # email
    email_service_name            = var.email_service_name
    email_port                    = var.email_container_port
  }
}

data "template_file" "nomad_job_redis" {
  template = file("${path.module}/conf/nomad/redis.hcl")
  vars = {
    # nomad
    datacenters        = local.datacenters
    # redis
    redis_service_name = var.redis_service_name
    redis_image        = var.redis_container_image
    redis_port         = var.redis_container_port
  }
}

data "template_file" "nomad_job_email" {
  template = file("${path.module}/conf/nomad/email.hcl")
  vars = {
    # nomad
    datacenters        = local.datacenters
    # email
    email_service_name = var.email_service_name
    email_image        = var.email_container_image
    email_port         = var.email_container_port
  }
}

resource "nomad_job" "nomad_job_redash_server" {
  jobspec = data.template_file.nomad_job_redash_server.rendered
  detach  = false
  depends_on = [
    nomad_job.nomad_job_redis,
    nomad_job.nomad_job_email
  ]
}

resource "nomad_job" "nomad_job_redash_worker" {
  jobspec = data.template_file.nomad_job_redash_worker.rendered
  detach  = false
  depends_on = [
    nomad_job.nomad_job_redash_server
  ]
}

resource "nomad_job" "nomad_job_redash_scheduler" {
  jobspec = data.template_file.nomad_job_redash_scheduler.rendered
  detach  = false
  depends_on = [
    nomad_job.nomad_job_redash_server
  ]
}

resource "nomad_job" "nomad_job_redis" {
  jobspec = data.template_file.nomad_job_redis.rendered
  detach  = false
}

resource "nomad_job" "nomad_job_email" {
  jobspec = data.template_file.nomad_job_email.rendered
  detach  = false
}
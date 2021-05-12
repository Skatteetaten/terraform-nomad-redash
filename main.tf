locals {
  datacenters              = join(",", var.nomad_datacenters)
  redash_config_properties = join(" && ", var.redash_config_properties)
}

data "template_file" "nomad_job_redash_server" {
  template = file("${path.module}/nomad/redash_server.hcl")
  vars = {
    datacenters              = local.datacenters
    namespace                = var.nomad_namespace
    image                    = var.container_image
    service                  = var.service
    host                     = var.host
    port                     = var.port
    cpu                      = var.resource.cpu
    memory                   = var.resource.memory
    cpu_proxy                = var.resource_proxy.cpu
    memory_proxy             = var.resource_proxy.memory
    use_canary               = var.use_canary
    redash_config_properties = local.redash_config_properties
    # Redis
    redis_service = var.redis_service.service
    redis_port    = var.redis_service.port
    # Postgres
    postgres_service = var.postgres_service.service
    postgres_port    = var.postgres_service.port
    # Trino
    trino_service = var.trino_service.service
    trino_port    = var.trino_service.port
  }
}

data "template_file" "nomad_job_redash_worker" {
  template = file("${path.module}/nomad/redash_worker.hcl")
  vars = {
    datacenters  = local.datacenters
    namespace    = var.nomad_namespace
    image        = var.container_image
    service      = var.service
    host         = var.host
    port         = var.port
    cpu          = var.resource.cpu
    memory       = var.resource.memory
    cpu_proxy    = var.resource_proxy.cpu
    memory_proxy = var.resource_proxy.memory
    use_canary   = var.use_canary
    # Redis
    redis_service = var.redis_service.service
    redis_port    = var.redis_service.port
    # Postgres
    postgres_service = var.postgres_service.service
    postgres_port    = var.postgres_service.port
    # Trino
    trino_service = var.trino_service.service
    trino_port    = var.trino_service.port
  }
}

data "template_file" "nomad_job_redash_scheduler" {
  template = file("${path.module}/nomad/redash_scheduler.hcl")
  vars = {
    datacenters  = local.datacenters
    namespace    = var.nomad_namespace
    image        = var.container_image
    service      = var.service
    host         = var.host
    port         = var.port
    cpu          = var.resource.cpu
    memory       = var.resource.memory
    cpu_proxy    = var.resource_proxy.cpu
    memory_proxy = var.resource_proxy.memory
    use_canary   = var.use_canary
    # Redis
    redis_service = var.redis_service.service
    redis_port    = var.redis_service.port
    # Postgres
    postgres_service = var.postgres_service.service
    postgres_port    = var.postgres_service.port
    # Trino
    trino_service = var.trino_service.service
    trino_port    = var.trino_service.port
  }
}



//data "template_file" "nomad_job_email" {
//  template = file("${path.module}/conf/nomad/email.hcl")
//  vars = {
//    # nomad
//    datacenters        = local.datacenters
//    # email
//    email_service_name = var.email_service_name
//    email_image        = var.email_container_image
//    email_port         = var.email_container_port
//    email_count        = var.email_count
//  }
//}

resource "nomad_job" "nomad_job_redash_server" {
  jobspec = data.template_file.nomad_job_redash_server.rendered
  detach  = false
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


//resource "nomad_job" "nomad_job_email" {
//  jobspec = data.template_file.nomad_job_email.rendered
//  detach  = false
//}
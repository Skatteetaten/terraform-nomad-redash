locals {
  datacenters              = join(",", var.nomad_datacenters)
  redash_config_properties = join(" ; ", var.redash_config_properties)
  redash_env_vars = join("\n", var.container_environment_variables)
}

data "template_file" "nomad_job_redash_server" {
  template = file("${path.module}/nomad/redash_server.hcl")
  vars = {
    datacenters              = local.datacenters
    namespace                = var.nomad_namespace
    image                    = var.container_image
    service_name             = var.service_name
    host                     = var.host
    port                     = var.port
    cpu                      = var.resource.cpu
    memory                   = var.resource.memory
    cpu_proxy                = var.resource_proxy.cpu
    memory_proxy             = var.resource_proxy.memory
    use_canary               = var.use_canary
    redash_config_properties = local.redash_config_properties
    envs                     = local.redash_env_vars
    # Redis
    redis_service = var.redis_service.service_name
    redis_port    = var.redis_service.port
    # Postgres
    postgres_service = var.postgres_service.service_name
    postgres_port    = var.postgres_service.port
    postgres_username = var.postgres_service.username
    postgres_password = var.postgres_service.password
    postgres_database_name = var.postgres_service.database_name
    # if creds ar provided by vault
    postgres_use_vault_provider      = var.postgres_vault_secret.use_vault_provider
    postgres_vault_kv_policy_name    = var.postgres_vault_secret.vault_kv_policy_name
    postgres_vault_kv_path           = var.postgres_vault_secret.vault_kv_path
    postgres_vault_kv_field_username = var.postgres_vault_secret.vault_kv_field_username
    postgres_vault_kv_field_password = var.postgres_vault_secret.vault_kv_field_password

    # Datasource upstreams
    upstreams = jsonencode(var.datasource_upstreams)
  }
}

data "template_file" "nomad_job_redash_worker" {
  template = file("${path.module}/nomad/redash_worker.hcl")
  vars = {
    datacenters  = local.datacenters
    namespace    = var.nomad_namespace
    image        = var.container_image
    service_name = var.service_name
    host         = var.host
    port         = var.port
    cpu          = var.resource.cpu
    memory       = var.resource.memory
    cpu_proxy    = var.resource_proxy.cpu
    memory_proxy = var.resource_proxy.memory
    use_canary   = var.use_canary
    # Redis
    redis_service = var.redis_service.service_name
    redis_port    = var.redis_service.port
    # Postgres
    postgres_service = var.postgres_service.service_name
    postgres_port    = var.postgres_service.port
    postgres_username = var.postgres_service.username
    postgres_password = var.postgres_service.password
    postgres_database_name = var.postgres_service.database_name
    # if creds ar provided by vault
    postgres_use_vault_provider      = var.postgres_vault_secret.use_vault_provider
    postgres_vault_kv_policy_name    = var.postgres_vault_secret.vault_kv_policy_name
    postgres_vault_kv_path           = var.postgres_vault_secret.vault_kv_path
    postgres_vault_kv_field_username = var.postgres_vault_secret.vault_kv_field_username
    postgres_vault_kv_field_password = var.postgres_vault_secret.vault_kv_field_password
    # Datasource upstreams
    upstreams = jsonencode(var.datasource_upstreams)
  }
}

data "template_file" "nomad_job_redash_scheduler" {
  template = file("${path.module}/nomad/redash_scheduler.hcl")
  vars = {
    datacenters  = local.datacenters
    namespace    = var.nomad_namespace
    image        = var.container_image
    service_name = var.service_name
    host         = var.host
    port         = var.port
    cpu          = var.resource.cpu
    memory       = var.resource.memory
    cpu_proxy    = var.resource_proxy.cpu
    memory_proxy = var.resource_proxy.memory
    use_canary   = var.use_canary
    # Redis
    redis_service = var.redis_service.service_name
    redis_port    = var.redis_service.port
    # Postgres
    postgres_service = var.postgres_service.service_name
    postgres_port    = var.postgres_service.port
    postgres_username = var.postgres_service.username
    postgres_password = var.postgres_service.password
    postgres_database_name = var.postgres_service.database_name

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
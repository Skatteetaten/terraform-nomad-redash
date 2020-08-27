
data "template_file" "nomad_job_redash_server" {
  template = "${file("${path.module}/conf/nomad/redash_server.hcl")}"
}

data "template_file" "nomad_job_redash_worker" {
  template = "${file("${path.module}/conf/nomad/redash_worker.hcl")}"
}

data "template_file" "nomad_job_redash_scheduler" {
  template = "${file("${path.module}/conf/nomad/redash_scheduler.hcl")}"
}

data "template_file" "nomad_job_postgres" {
  template = "${file("${path.module}/conf/nomad/postgres.hcl")}"
}

data "template_file" "nomad_job_redis" {
  template = "${file("${path.module}/conf/nomad/redis.hcl")}"
}

data "template_file" "nomad_job_email" {
  template = "${file("${path.module}/conf/nomad/email.hcl")}"
}

resource "nomad_job" "nomad_job_redash_server" {
  jobspec = "${data.template_file.nomad_job_redash_server.rendered}"
  depends_on = [
    "nomad_job.nomad_job_redis",
    "nomad_job.nomad_job_postgres",
    "nomad_job.nomad_job_email",
  ]
}

resource "nomad_job" "nomad_job_redash_worker" {
  jobspec = "${data.template_file.nomad_job_redash_worker.rendered}"
  depends_on = [
    "nomad_job.nomad_job_redash_server",
  ]
}

resource "nomad_job" "nomad_job_redash_scheduler" {
  jobspec = "${data.template_file.nomad_job_redash_scheduler.rendered}"
  depends_on = [
    "nomad_job.nomad_job_redash_server",
  ]
}

resource "nomad_job" "nomad_job_postgres" {
  jobspec = "${data.template_file.nomad_job_postgres.rendered}"
}

resource "nomad_job" "nomad_job_redis" {
  jobspec = "${data.template_file.nomad_job_redis.rendered}"
}

resource "nomad_job" "nomad_job_email" {
  jobspec = "${data.template_file.nomad_job_email.rendered}"
}
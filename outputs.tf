# Redash
output "redash_server_service" {
  description = "Redash server service name"
  value       = data.template_file.nomad_job_redash_server.vars.service_name
}

output "redash_worker_service" {
  description = "Redash worker service name"
  value       = data.template_file.nomad_job_redash_worker.vars.service_name
}

output "redash_scheduler_service" {
  description = "Redash scheduler service name"
  value       = data.template_file.nomad_job_redash_scheduler.vars.service_name
}
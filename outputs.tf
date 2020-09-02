# Redash
output "redash_admin_username" {
  description = "Redash admin username"
  value       = data.template_file.nomad_job_redash_server.vars.redash_admin_username
}

output "redash_admin_password" {
  description = "Redash admin password"
  value       = data.template_file.nomad_job_redash_server.vars.redash_admin_password
}

output "redash_admin_email_id" {
  description = "Redash admin email id"
  value       = data.template_file.nomad_job_redash_server.vars.redash_admin_email_id
}

output "redash_server_service_name" {
  description = "Redash server service name"
  value       = data.template_file.nomad_job_redash_server.vars.redash_server_service_name
}

output "redash_worker_service_name" {
  description = "Redash worker service name"
  value       = data.template_file.nomad_job_redash_worker.vars.redash_worker_service_name
}

output "redash_scheduler_service_name" {
  description = "Redash scheduler service name"
  value       = data.template_file.nomad_job_redash_scheduler.vars.redash_scheduler_service_name
}

output "redash_container_port" {
  description = "Redash container port"
  value       = data.template_file.nomad_job_redash_server.vars.redash_port
}
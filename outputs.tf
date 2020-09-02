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
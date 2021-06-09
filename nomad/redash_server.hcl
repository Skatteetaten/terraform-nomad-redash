job "${service_name}-server" {
  type        = "service"
  datacenters = ["${datacenters}"]
  namespace   = "${namespace}"

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "55m"
    progress_deadline = "1h"
%{ if use_canary }
    canary            = 1
    auto_promote      = true
    auto_revert       = true
%{ endif }
    stagger           = "30s"
  }

  group "redash-server" {
    count = 1

    network {
      mode = "bridge"
      port "expose_check" {
        to = -1
      }
    }

    service {
      name = "${service_name}-server"
      port = "${port}"

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "${redis_service}"
              local_bind_port  = "${redis_port}"
            }
            upstreams {
              destination_name = "${postgres_service}"
              local_bind_port  = "${postgres_port}"
            }
%{ for upstream in jsondecode(upstreams) }
            upstreams {
              destination_name = "${upstream.service_name}"
              local_bind_port  = "${upstream.port}"
            }
%{ endfor }
            expose {
              path {
                path            = "/ping"
                protocol        = "http"
                local_path_port = ${port}
                listener_port   = "expose_check"
              }
            }
          }
        }
        sidecar_task {
          resources {
            cpu     = "${cpu_proxy}" # MHz
            memory  = "${memory_proxy}" #MB
          }
        }
      }
    }

    task "redash-server" {
      driver = "docker"
      config {
        image = "${image}"
        command = "/bin/bash"
        args = [
          "-c",
          "${redash_config_properties}"
        ]
      }

      template {
        destination = ".env"
        env = true
        data = <<EOF
PYTHONUNBUFFERED = 0
REDASH_LOG_LEVEL = "INFO"
REDASH_REDIS_URL = "redis://{{ env "NOMAD_UPSTREAM_ADDR_${redis_service}" }}/0"
%{ if postgres_use_vault_provider }
{{ with secret "${postgres_vault_kv_path}" }}
REDASH_DATABASE_URL = "postgresql://"{{ .Data.data.${postgres_vault_kv_field_username} }}":"{{ .Data.data.${postgres_vault_kv_field_password} }}"@{{ env "NOMAD_UPSTREAM_ADDR_${postgres_service}" }}/${postgres_database_name}"
{{ end }}
%{ else }
REDASH_DATABASE_URL = "postgresql://${postgres_username}:${postgres_password}@{{ env "NOMAD_UPSTREAM_ADDR_${postgres_service}" }}/${postgres_database_name}"
%{ endif }
REDASH_RATELIMIT_ENABLED = "false"
REDASH_ENFORCE_CSRF = "true"
EOF
}

      template {
        destination = "local/data/.additional-envs"
        change_mode = "noop"
        env         = true
        data        = <<EOF
%{ if ldap_use_vault_provider }
{{ with secret "${ldap_vault_kv_path}" }}
REDASH_LDAP_BIND_DN="{{ .Data.data.${ldap_vault_kv_field_username} }}"
REDASH_LDAP_BIND_DN_PASSWORD="{{ .Data.data.${ldap_vault_kv_field_password} }}"
{{ end }}
%{ endif }
${envs}
EOF
}
      resources {
        cpu    = "${cpu}" # MHz
        memory = "${memory}" # MB
      }
    }
  }
}

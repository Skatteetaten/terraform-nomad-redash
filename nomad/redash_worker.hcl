job "redash-worker" {
  datacenters = "${datacenters}"
  type        = "service"

  group "redash-worker" {
    count = "${redash_worker_count}"

    network {
      mode = "bridge"
    }

    service {
      name = "${redash_worker_service_name}"
      tags = ["redash", "redash-worker"]
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "${redis_service_name}"
              local_bind_port  = "${redis_port}"
            }
            upstreams {
              destination_name = "${postgres_service_name}"
              local_bind_port  = "${postgres_port}"
            }
            upstreams {
              destination_name = "${email_service_name}"
              local_bind_port  = "${email_port}"
            }
            upstreams {
              destination_name = "${presto_service_name}"
              local_bind_port  = "${presto_container_port}"
            }
          }
        }
      }
    }

    task "redash-worker" {
      driver  = "docker"
      config {
        image = "${redash_image}"
        args  = ["worker"]
      }

      env {
        PYTHONUNBUFFERED           = 0
        REDASH_LOG_LEVEL           = "INFO"
        REDASH_REDIS_URL           = "redis://$${NOMAD_UPSTREAM_ADDR_${redis_service_name}}/0"
        REDASH_DATABASE_URL        = "postgresql://${postgres_username}:${postgres_password}@$${NOMAD_UPSTREAM_ADDR_${postgres_service_name}}/${postgres_service_name}"
        REDASH_MAIL_DEFAULT_SENDER = "redash@example.com"
        REDASH_MAIL_SERVER         = "http://$${NOMAD_UPSTREAM_ADDR_${email_service_name}}"
        REDASH_MAIL_PORT           = "${redash_mail_port}"
      }

      resources {
          cpu    = "${redash_cpu}"
          memory = "${redash_memory}"
      }
    }
  }
}
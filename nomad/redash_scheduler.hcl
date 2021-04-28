job "redash-scheduler" {
  datacenters = "${datacenters}"
  type        = "service"

  group "redash-scheduler" {
    count = "${redash_scheduler_count}"

    network {
      mode = "bridge"
    }

    service {
      name = "${redash_scheduler_service_name}"
      tags = ["redash", "redash-scheduler"]
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
          }
        }
      }
    }

    task "redash-scheduler" {
      driver = "docker"
      config {
        image = "${redash_image}"
        args  = ["scheduler"]
      }

      env {
        REDASH_REDIS_URL           = "redis://$${NOMAD_UPSTREAM_ADDR_${redis_service_name}}/0"
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

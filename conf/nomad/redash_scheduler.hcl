job "redash-scheduler" {
  datacenters = ["dc1"]
  type        = "service"

  group "redash-scheduler" {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "redash-redash-scheduler-service"
      tags = ["redash", "redash-scheduler"]
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "redash-redis-service"
              local_bind_port = 6379
            }
            upstreams {
              destination_name = "${postgres_service_name}"
              local_bind_port = "${postgres_port}"
            }
            upstreams {
              destination_name = "redash-email-service"
              local_bind_port = 80
            }
          }
        }
      }
    }

    task "redash-scheduler" {
      driver = "docker"
      config {
        image = "redash/redash:8.0.2.b37747"
        args = ["scheduler"]
      }

      env {
        REDASH_REDIS_URL = "redis://$${NOMAD_UPSTREAM_ADDR_redash_redis_service}/0"
        REDASH_MAIL_DEFAULT_SENDER = "redash@example.com"
        REDASH_MAIL_SERVER = "http://$${NOMAD_UPSTREAM_ADDR_redash_email_service}"
        REDASH_MAIL_PORT = 25
      }

      resources {
          cpu    = 500
          memory = 1028
      }
    }
  }
}

job "redash-worker" {
  datacenters = ["dc1"]
  type        = "service"

  group "redash-worker" {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "redash-worker-service"
      tags = ["redash", "redash-worker"]
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "redash-redis-service"
              local_bind_port = 6379
            }
            upstreams {
              destination_name = "redash-postgres-service"
              local_bind_port = 5432
            }
            upstreams {
              destination_name = "redash-email-service"
              local_bind_port = 80
            }
            upstreams {
              destination_name = "presto"
              local_bind_port = 8080
            }
          }
        }
      }
      
    }

    task "redash-worker" {
      driver = "docker"
      config {
        image = "redash/redash:8.0.2.b37747"
        args = ["worker"]
      }

      env {
        PYTHONUNBUFFERED = 0
        REDASH_LOG_LEVEL = "INFO"
        REDASH_REDIS_URL = "redis://$${NOMAD_UPSTREAM_ADDR_redash_redis_service}/0"
        REDASH_DATABASE_URL = "postgresql://postgres@$${NOMAD_UPSTREAM_ADDR_redash_postgres_service}/postgres"
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
job "redash-server" {
  datacenters = ["dc1"]
  type        = "service"

  group "redash-server" {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "redash-redash-server-service"
      port = 5000
      tags = ["redash", "redash-server"]
      check {
        expose    = true
        name      = "redash-server-live"
        type      = "http"
        path      = "/ping"
        interval  = "10s"
        timeout   = "2s"
      }
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
          }
        }
      }
    }

    task "redash-server" {
      driver = "docker"
      config {
        image = "redash/redash:8.0.2.b37747"
        command = "/bin/bash"
        args = [
          "-c",
          "python /app/manage.py database create_tables && /usr/local/bin/gunicorn -b 0.0.0.0:5000 --name redash -w4 redash.wsgi:app --max-requests 1000 --max-requests-jitter 100"
        ]
      }

      env {
        PYTHONUNBUFFERED = 0
        REDASH_LOG_LEVEL = "INFO"
        REDASH_REDIS_URL = "redis://$${NOMAD_UPSTREAM_ADDR_redash_redis_service}/0"
        REDASH_DATABASE_URL = "postgresql://postgres@$${NOMAD_UPSTREAM_ADDR_redash_postgres_service}/postgres"
        REDASH_RATELIMIT_ENABLED = "false"
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

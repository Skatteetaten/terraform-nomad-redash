job "redash-server" {
  datacenters = "${datacenters}"
  type        = "service"

  group "redash-server" {
    count = "${redash_server_count}"

    network {
      mode = "bridge"
    }

    service {
      name = "${redash_server_service_name}"
      port = "${redash_port}"
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

    task "redash-server" {
      driver = "docker"
      config {
        image   = "${redash_image}"
        command = "/bin/bash"
        args = [
          "-c",
          "python /app/manage.py database create_tables && python /app/manage.py users create_root ${redash_admin_email_id} ${redash_admin_username} --password ${redash_admin_password} --org default && /usr/local/bin/gunicorn -b 0.0.0.0:5000 --name redash -w4 redash.wsgi:app --max-requests 1000 --max-requests-jitter 100"
        ]
      }

      env {
        PYTHONUNBUFFERED           = 0
        REDASH_LOG_LEVEL           = "INFO"
        REDASH_REDIS_URL           = "redis://$${NOMAD_UPSTREAM_ADDR_${redis_service_name}}/0"
        REDASH_DATABASE_URL        = "postgresql://${postgres_username}:${postgres_password}@$${NOMAD_UPSTREAM_ADDR_${postgres_service_name}}/${postgres_service_name}"
        REDASH_RATELIMIT_ENABLED   = "false"
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

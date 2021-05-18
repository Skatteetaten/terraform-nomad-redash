job "redash-scheduler" {
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

  group "redash-scheduler" {
    count = 1

    network {
      mode = "bridge"
    }

    service {
      name = "${service_name}-scheduler"
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

    task "redash-scheduler" {
      driver = "docker"
      config {
        image = "${image}"
        args  = ["scheduler"]
      }

      env {
        REDASH_REDIS_URL = "redis://$${NOMAD_UPSTREAM_ADDR_${redis_service}}/0"
      }

      resources {
        cpu    = "${cpu}" # MHz
        memory = "${memory}" # MB
      }
    }
  }
}

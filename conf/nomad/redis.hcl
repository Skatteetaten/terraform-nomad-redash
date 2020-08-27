job "redis" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 100

  group "redis" {
    count = 1
    network {
      mode = "bridge"
    }

    service {
      name = "redash-redis-service"
      port = 6379
      tags = ["redash", "redis"]
      connect {
        sidecar_service {}
      }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "redis:3-alpine"
      }
    }
  }
}

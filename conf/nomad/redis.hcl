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

      check {
        type     = "script"
        name     = "redash-redis-alive"
        task     = "redis-service"
        command  = "redis-cli"
        args     = ["ping"]
        interval = "5s"
        timeout  = "5s"
      }

      connect {
        sidecar_service {}
      }
    }

    task "redis-service" {
      driver = "docker"
      config {
        image = "redis:3-alpine"
      }
    }
  }
}

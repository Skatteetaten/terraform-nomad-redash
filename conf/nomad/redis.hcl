job "redash-redis" {
  datacenters = "${datacenters}"
  type        = "service"
  priority    = 100

  group "redash-redis" {
    count = 1
    network {
      mode = "bridge"
    }

    service {
      name = "${redis_service_name}"
      port = "${redis_port}"
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
        image = "${redis_image}"
      }
    }
  }
}

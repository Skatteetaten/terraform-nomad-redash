job "redash-email" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 100
  
  group "redash-email" {
    count = 1
    network {
      mode = "bridge"
    }

    service {
      name = "redash-email-service"
      port = 80
      tags = ["redash", "email"]
      check {
        expose    = true
        name      = "redash-email-live"
        type      = "http"
        path      = "/healthz"
        interval  = "10s"
        timeout   = "2s"
      }
      connect {
        sidecar_service {}
      }
    }

    task "email-service" {
      driver = "docker"
      config {
        image = "djfarrelly/maildev:1.1.0"
      }
    }
  }
}

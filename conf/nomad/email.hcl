job "email" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 100
  
  group "email" {
    count = 1
    network {
      mode = "bridge"
    }

    service {
      name = "redash-email-service"
      port = 80
      tags = ["redash", "email"]
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

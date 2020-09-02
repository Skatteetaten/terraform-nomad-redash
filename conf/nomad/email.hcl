job "redash-email" {
  datacenters = "${datacenters}"
  type        = "service"
  priority    = 100
  
  group "redash-email" {
    count = 1
    network {
      mode = "bridge"
    }

    service {
      name = "${email_service_name}"
      port = "${email_port}"
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
        image = "${email_image}"
      }
    }
  }
}

job "postgres" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 100

  group "postgres" {
    count = 1
    
    network {
      mode = "bridge"
    }

    service {
      name = "redash-postgres-service"
      port = 5432
      tags = ["redash", "postgres"]
      connect {
        sidecar_service {}
      }
    }

    task "postgres" {
      driver = "docker"
      config {
        image = "postgres:9.5-alpine"
        command = "postgres"
        args = [
          "-c",
          "fsync=off",
          "-c", 
          "full_page_writes=off",
          "-c",
          "synchronous_commit=OFF"
        ] 
      }
      
      env {
        POSTGRES_HOST_AUTH_METHOD = "trust"
      }
    }
  }
}
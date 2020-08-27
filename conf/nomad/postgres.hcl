job "redash-postgres" {
  datacenters = ["dc1"]
  type        = "service"
  priority    = 100

  group "redash-postgres" {
    count = 1
    
    network {
      mode = "bridge"
    }

    service {
      name = "redash-postgres-service"
      port = 5432
      tags = ["redash", "postgres"]
      check {
        type     = "script"
        name     = "redash-postgres-alive"
        task     = "postgres-service"
        command  = "/usr/local/bin/pg_isready"
        args     = ["-U", "postgres", "--timeout=5"]
        interval = "5s"
        timeout  = "5s"
      }
      connect {
        sidecar_service {}
      }
    }

    task "postgres-service" {
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
<!-- markdownlint-disable MD041 -->
<p align="center"><img width="100px" src="https://www.svgrepo.com/show/48203/chart.svg" align="center" alt="Vagrant-hashistack" /><h2 align="center">Redash Terraform Module</h2></p><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>

## Content
1. [Compatibility](#compatibility)
2. [Requirements](#requirements)
    1. [Required modules](#required-modules)
    2. [Required software](#required-software)
3. [Usage](#usage)
    1. [Verifying setup](#verifying-setup)
    2. [Providers](#providers)
4. [Example usage](#example-usage)
5. [Inputs](#inputs)
6. [Outputs](#outputs)
7. [License](#license)

## Compatibility
|Software|OSS Version|Enterprise Version|
|:---|:---|:---|
|Terraform|0.13.1 or newer||
|Consul|1.8.3 or newer|1.8.3 or newer|
|Vault|1.5.2.1 or newer|1.5.2.1 or newer|
|Nomad|0.12.3 or newer|0.12.3 or newer|

## Usage
### Requirements

### Required modules
| Module | Version |
|:---|:---|
| [terraform-nomad-postgres](https://github.com/Skatteetaten/terraform-nomad-postgres) | 0.4.0 or newer |
| [terraform-nomad-redis](https://github.com/Skatteetaten/terraform-nomad-redis) | 0.1.0 or newer |

### Required software
All software is provided and run with docker. See the [Makefile](Makefile) for inspiration.

## Usage
The following command will run Redash in the [example/redash_one_node](example/redash_one_node) folder.
```sh
make up-redash-one-node
```

### Verifying setup
You can verify that Redash ran successful by checking the Redash UI.

First create a proxy to connect with the Redash service:
```text
make proxy-redash
```

You can now visit the UI on [localhost:5000/](http://localhost:5000/).

### Providers
- [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)
- [Vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)


## Example usage
Example-code that shows how to use the module and, if applicable, its different use cases.
```hcl
module "redash" {
  source = "../.."
  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # redash
  service         = "redash"
  host            = "127.0.0.1"
  port            = 5000
  container_image = "redash/redash:9.0.0-beta.b42121"

  postgres_service = {
    service_name  = module.redash-postgres.service_name
    port          = module.redash-postgres.port
    username      = module.redash-postgres.username
    password      = module.redash-postgres.password
    database_name = module.redash-postgres.database_name
  }
  postgres_vault_secret = {
    use_vault_provider      = true
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/dev/postgres"
    vault_kv_field_username = "username"
    vault_kv_field_password = "password"
  }
}

module "redis" {
  source = "github.com/Skatteetaten/terraform-nomad-redis.git?ref=0.1.0"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # redis
  service_name    = "redis"
  host            = "127.0.0.1"
  port            = 6379
  container_image = "redis:3-alpine"
}

module "postgres" {
  source = "github.com/Skatteetaten/terraform-nomad-postgres.git?ref=0.4.1"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # postgres
  service_name    = "postgres"
  container_image = "postgres:12-alpine"
  container_port  = 5432
  vault_secret = {
    use_vault_provider      = false
    vault_kv_policy_name    = "kv-secret"
    vault_kv_path           = "secret/data/dev/postgres"
    vault_kv_field_username = "username"
    vault_kv_field_password = "password"
  }
  database                        = "metastore"
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = false
}
```
## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nomad\_datacenters | Nomad data centers | list(string) | ["dc1"] | yes |
| nomad\_namespace | [Enterprise] Nomad namespace | string | "default" | yes |
| service_name | Redash service name | string | "redash" | yes |
| host | Redash host | string | "127.0.0.1" | yes |
| port | Redash container port | number | 5000 | yes |
| container\_image | Redash container image | string | "redash/redash:9.0.0-beta.b42121" | yes |
| resource | Resource allocations for cpu and memory | obj(number, number)| { <br> cpu = 200, <br> memory = 1024 <br> } | no |
| resource_proxy | Resource allocations for proxy | obj(number, number)| { <br> cpu = 200, <br> memory = 128 <br> } | no |
| use\_canary | Uses canary deployment for Redash | bool | false | no |
| redash\_config\_properties | Custom redash configuration properties | list(string) | [<br> "python /app/manage.py database create_tables", <br> "python /app/manage.py users create_root admin@mail.com admin123 --password admin --org default", <br> "/usr/local/bin/gunicorn -b 0.0.0.0:5000 --name redash -w4 redash.wsgi:app --max-requests 1000 --max-requests-jitter 100" <br> ] | no |
| container\_environment\_variables | Redash environment variables | list(string) | [" "] | no |
| redis\_service | Redis data-object contains service_name and port. | obj(string, string) | { <br> service = "redash-redis", <br> port = 6379, <br> host = "127.0.0.1" <br> } | no |
| postgres\_service | Postgres data-object contains service, port, username, password and database name | obj(string, number, string, string, string) | { <br> service = "redash-postgres", <br> port = 5432, <br> username = "username", <br> password = "password",  <br> database_name = "metastore" } | no |
| postgres_vault_secret | Set of properties to be able to fetch Postgres secrets from vault | obj(bool, string, string, string, string) | { <br> use_vault_provider = false, <br> vault_kv_policy_name = "kv-secret", <br> vault_kv_path = "secret/data/dev/trino", <br> vault_kv_field_username = "username", <br> vault_kv_field_password = "username" <br> } | no |
| datasource\_upstreams | List of upstream services (list of object with service_name, port) | list | [" "] | no |

## Outputs
| Name | Description | Type |
|------|-------------|------|
| redash\_server\_service | redash server service name | string |
| redash\_worker\_service | redash worker service name | string |
| redash\_scheduler\_service | redash scheduler service name | string |


## License
This work is licensed under Apache 2 License. See [LICENSE](./LICENSE) for full details.

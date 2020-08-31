<!-- markdownlint-disable MD041 -->
<p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>

# Redash terraform module

## Compatibility
|Software|OSS Version|Enterprise Version|
|:--|:--|:--|
|Terraform|0.13.1 or newer||
|Consul|1.8.3 or newer|1.8.3 or newer|
|Vault|1.5.2.1 or newer|1.5.2.1 or newer|
|Nomad|0.12.3 or newer|0.12.3 or newer|

## Usage

### Starting datastack
Run
```makefile
make up
```
in your terminal to provision the datastack. When the process is finished you can then open up access to Redash, Presto, and MinIO by running
```makefile
make connect-to-all
```
which will open 3 terminal windows each with a connection to one of the components. Alternatively you can run `make proxy-redash`, `make proxy-presto`, and `make proxy-minio` to open individual proxy connections.

### Requirements
#### Required modules
- [MinIO](https://github.com/fredrikhgrelland/terraform-nomad-minio)
- [Hive](https://github.com/fredrikhgrelland/terraform-nomad-hive)

#### Required software
- [GNU make](https://man7.org/linux/man-pages/man1/make.1.html)
- [consul](https://www.consul.io/)

### Providers
This module uses the [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs).

## Inputs
|Name     |Description     |Type    |Default |Required  |
|:--|:--|:--|:-:|:-:|
|         |                |bool    |true    |yes        |

## Outputs
|Name     |Description     |Type    |Default |Required   |
|:--|:--|:--|:-:|:-:|
|         |                |bool    |true    |yes         |

### Example
Example-code that shows how to use the module, and, if applicable, its different use cases.
```hcl-terraform
module "example"{
  source = "github.com/fredrikhgrelland/terraform-nomad-redash.git?ref=0.0.1"
}
```

### Verifying setup
Description of expected end result and how to check it. E.g. "After a successful run Presto should be available at localhost:8080".

## Authors

## License
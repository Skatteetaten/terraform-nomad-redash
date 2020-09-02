<!-- markdownlint-disable MD041 -->
<p align="center"><img width="100px" src="https://www.svgrepo.com/show/48203/chart.svg" align="center" alt="Vagrant-hashistack" /><h2 align="center">Redash Terraform Module</h2></p><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>

## Contents
1. [Compatibility](#compatibility)
2. [Usage](#usage)
   1. [Requirements](#requirements)
      1. [Required software](#required-software)
   2. [Providers](#providers)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Examples](#examples)
6. [Authors](#authors)
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

#### Required software
See [template README's prerequisites](template_README.md#install-prerequisites).

### Providers
This module uses the [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs) provider.

## Inputs
Name     |Description     |Type    |Default |Required   |
|:---|:---|:---|:---|:---|
|   redash_email_id   | Redash admin username| string    |admin@mail.com    |   no |
|   redash_password  |  Redash admin password| string    |admin123         |    no |
|   redash_username |   Redash admin username| string    |admin           |     no |


## Outputs
|Name     |Description     |Type    |Default |Required   |
|:---|:---|:---|:---|:---|
|   redash_email_id   | Redash admin username| string    |admin@mail.com    |   no |
|   redash_password  |  Redash admin password| string    |admin123         |    no |
|   redash_username |   Redash admin username| string    |admin           |     no |

## Examples
 Import module:
```hcl-terraform
module "example"{
  source = "github.com/fredrikhgrelland/terraform-nomad-redash.git?ref=0.0.1"
}
```

There are also several examples using this terraform module:

|Name|Path to Documentation|Description|
|:--|:--|:--|
|Datastack|[example/datastack](example/datastack/README.md)|Sets up a full datastack with Redash, Presto, and MinIO|
|Redash one node|[example/redash_one_node/](example/redash_one_node/README.md)|Sets up a single instance of Redash and its UI|

### Verifying setup
Description of expected end result and how to check it. E.g. "After a successful run Presto should be available at localhost:8080".

## Authors

## License
# Terraform module example
The current directory contains terraform related files that use the module in `../`. See [template_example](../template_example/example/).

All examples have their own directories, with a `main.tf` that references one or more modules.

| Examples       |
| :------------- |
| [Redash one node](redash_one_node) |
| [Redash connected to Trino as a datasource](redash_trino_cluster) |

## References
- [Creating Modules - official terraform documentation](https://www.terraform.io/docs/modules/index.html)
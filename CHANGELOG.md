# Changelog
## [1.0.1 UNRELEASED]

### Updated

### Added
- Fetch ldap secrets from Vault #50
- Used `create_datasource.py` (function in redash image = `gitlab-container-registry.minerva.loc/datainn/redash-rabbit-edition:ptmin-1394-create-datasources` ) to prevent duplicate data sources in example/redash_trino_cluster #51
- Vault integration: admin and admin-password (root-user) redash-server #52
- Moved all secrets to /secrets/.env #55

### Deleted

## [1.0.0]
### Updated
- Documentation for example/redash_trino_cluster #40
- Documentation for example/redash_one_node #38
- Bump vagrant-hashistack ">= 0.10, < 0.11". #32
- Removed unused files/folders and updated the folder structure. #32
- Updated example/redash_one_node with upstream to postgres and redis, and dynamical variables. #34

### Added
- Added a new example/redash_trino_cluster #39
- Added variable `redash_config_properties` for custom redash properties. This variable makes it possible to create a new data source dynamically. #39
- Integration with Vault #35
- Random env-vars #43
- Added health checks for redash-server #36


## [0.0.3]

### Added
- update-box as a prereq for the template-example target in the makefile
- Check for presence of consul binary
- Consul in the Required software section of the README file
- Implemented terraform-nomad-postgres module instead of local postgres
- Added postgres variables
- default admin user for redash on startup
- Added variables

### Fixed
- Corrected the link to the proxy section that shows up when the make command fails
- Makefile `connect-to-all` supports opening multiple terminals for both Linux and MacOS
- Corrected `proxy-redash` to point to default redash service name (same as in variables.tf)

## [0.0.2]

### Changed
- Increased resources allocated to vagrant-box

### Added
- README section `Starting datastack`
- Added example `datastack`
- Added connection to presto

### Fixed

## [0.0.1]

### Changed
- Changed README to TF-module readme

### Added
- Added CHANGELOG.md
- Added redash-one-node example
- Added redash module

### Fixed

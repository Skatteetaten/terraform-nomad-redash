# Changelog

## [0.1.0 UNRELEASED]

### Updated
- Bump version of vagrant box ">= 0.4, < 0.5". #32
- Removed unused files/folders and updated the folder structure. #32

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

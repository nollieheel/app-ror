# app_ror CHANGELOG

## 5.0.1 - 2024-05-27
### Added
- Add su directive to logrotate conf (user: ubuntu, group: ubuntu)

## 5.0.0 - 2024-05-09
### Breaking changes
- Remove support for Ubuntu 20.04
- NodeJS always uses nodesource repo except for version 12.x

### Added
- Use 'notify' unit type for Puma service
- Yarn version can now be set via cookbook, although choices are limited by NodeJS version

### Changed
- Updated Chef Infra client version
- Update the ruby_build ref for ruby resource
- Updated the repo install method for Ubuntu repos

### Removed
- Dependencies to yarn cookbook

## 4.1.0 - 2023-04-23
### Added
- New resource app_ror_gem to install Ruby gems

## 4.0.0 - 2023-04-19
### Breaking changes
- Removed dependency from nodejs cookbook
- NodeJS and Yarn are now a separate resource `app_ror_nodejs`

### Changed 
- :conf_file property of manage_sidekiq resource can now be turned off

### Added
- :unit_type and :watchdogsec properties to manage_sidekiq resource

## 3.2.0 - 2022-11-10
### Changed
- Updated dependency versions
- /etc/environment should now be updated to match at every resource call
- Changed default number of sidekiq processes from 1 to 2

### Removed
- Property 'ruby_bin_path' and 'bashrc_prepend_env' from resource 'app_ror_ruby'
- Property 'base_dir' from resource 'app_ror_manage_puma'
- Property 'base_dir' from resource 'app_ror_manage_sidekiq'

### Added
- Basic resource app_ror_redis for testing
- Tests

## 3.1.0 - 2021-11-05
### Changed
- Property 'bashrc_prepend_env' for resource 'app_ror_ruby' is now DEPRECATED.

### Removed
- Attributes removed from cookbook
- Remove app_ror_solr resource

## 3.0.0 - 2021-10-27
### Changed
- BREAKING changes all around
- Renamed cookbook  to `app_ror`
- Made compatible with Chef 17.x

## 2.2.1 - 2019-08-12
### Fixed
- Fixed bug where Solr service is left in stopped state if there are no modifications to `solr.in.sh`.

## 2.2.0 - 2019-06-26
### Added
- Resource `ruby`: Add property `bashrc_prepend_env` as an option to prepend the environment variable declarations into `.bashrc`, instead of appending them at the end of the file.
- Updated copyright years.

## 2.1.1 - 2019-06-17
### Fixed
- Resource `solr`: remove quotes on numeric config values in `solr.in.sh`.

## 2.1.0 - 2018-11-10
### Changed
- Resource `app_ror_ruby`: rename property `export_env_file` to `export_ruby_env`.

### Added
- Resource `app_ror_ruby`: add property `bundler_version` for finer grained Bundler installation.
- Resource `app_ror_ruby`: add property `ruby_env` to customize environment variables for Ruby.

## 2.0.0 - 2018-10-17
### Changed
- BREAKING CHANGES to most resources!
- Use ruby-build for Ruby installation.

### Added
- Add support for both Chef 13 and Chef 14.
- Add support for Ubuntu >= 14.04, especially Systemd.
- Add tests.

## 1.0.2 - 2018-06-25
### Fixed
- Forgot to update cookbook version in metadata.rb.

## 1.0.1 - 2018-06-22
### Added
- Use Nodejs 8.x by default.

### Removed
- Remove boolean false as argument for app_ror_swap file property.

## 1.0.0 - 2018-06-20
### Added
- First version of cookbook

## beta - 2018-06-02
### Added
- First commit of cookbook skeleton.

---
Changelog format reference: http://keepachangelog.com/en/0.3.0/

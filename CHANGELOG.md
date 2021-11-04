# app_ror CHANGELOG

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

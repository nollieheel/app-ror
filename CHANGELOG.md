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

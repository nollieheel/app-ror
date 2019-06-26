# app-ror cookbook

Some cookbook resources to ease setup of Ruby-on-Rails apps.

## Supported Platforms

Ubuntu >= 14.04

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['app-ror']['ruby']['apt_packages']</tt></td>
    <td>Array</td>
    <td>Default OS packages needed for Ruby.</td>
    <td><tt>(See attribute file)</tt></td>
  </tr>
  <tr>
    <td><tt>['app-ror']['solr']['apt_packages']</tt></td>
    <td>Array</td>
    <td>Default OS packages needed for Solr.</td>
    <td><tt>(See attribute file)</tt></td>
  </tr>
</table>

## Resources

### app_ror_swap

Create a swap file and enable it. _Deprecated in Chef 14 (use built-in resource 'swap\_file', instead)._

```ruby
app_ror_swap '/swapfile' do
  size 1024
end
```

#### Actions

- `create` - Create the swap file (default)

#### Properties:

- `file` - Name of swapfile. Defaults to name of resource.
- `size` - Size of swap in MB. Defaults to `4096`.

### app_ror_base_dirs

Simply create directories.

```ruby
app_ror_base_dirs '/var/src/myapp' do
  owner 'john'
  sub_dirs ['shared', 'shared/config']
end
```

#### Actions

- `create` - Create the directories (default)

#### Properties

- `base_dir` - The directory path. Defaults to name of resource.
- `owner` - Owner of directories.
- `group` - Group name of directories. Defaults to owner name.
- `sub_dirs` - Relative subdirectory/ies that should also be created. Can be given as an Array. Defaults to `'shared'`.

### app_ror_logrotate

Add some logrotate configurations.

```ruby
app_ror_logrotate 'myapp' do
  path '/var/src/myapp/shared/log/*.log'
end
```

#### Actions

- `create` - Create the logrotate configs (default)

#### Properties

- `filename` - File name of config. Defaults to name of resource.
- `path` - Path to be logrotated. Can also be an Array.
- `config` - Logrotate directives. Defaults to:
```
weekly
missingok
rotate 12
compress
delaycompress
notifempty
copytruncate
```
- `configs` - If multiple configs are desired, `path` and `config` can be ommitted. Instead, use this property and pass an Array of Hashes, each with their own `:filename`, `:path`, and `:config` keys. Example:
```
app_ror_logrotate 'foo' do
  configs([
    {
      :filename => 'myapp',
      :path => ['/var/src/myapp/shared/log/*.log', '/var/src/myapp/logs/*']
    },
    {
      :filename => 'anotherapp',
      :path => '/var/src/anotherapp/logs/*.log',
      :config => [ 'weekly', 'notifempty' ]
    }
  ])
end
```

### app_ror_ruby

Install Ruby using [Ruby-build](https://github.com/rbenv/ruby-build).

```ruby
app_ror_ruby '2.5.1' do
  user 'john'
  gem_path '/opt/ruby_build/builds/2.5.1/lib/ruby/gems/2.5.0'
  gems([
    { :gem => 'rails', :version => '5.1.6' },
    { :gem => 'sidekiq', :version => '5.1.3' }
  ])
end
```

#### Actions

- `install` - Install Ruby (default)

#### Properties

- `version` - Ruby version. Defaults to name of resource.
- `bundler_version` - If not set, latest bundler version is installed.
- `user` - Main user assigned to this installation.
- `bin_path` - Location of Ruby installation binaries. Default: `{prefix}/builds/{version}/bin`.
- `gem_home` - Default: `/home/{user}/.gem/ruby/{version}`.
- `gem_path` - Default: `{prefix}/builds/{version}/lib/ruby/gems/{version}`. The actual resolved `GEM_PATH` will always also include `GEM_HOME`, so there is no need to include it here. _Note: Always verify this path, especially for new Ruby patch versions, which don't seem to follow this default path naming scheme._
- `ruby_env` - Additional environment variables if needed. Default: `{}`.
- `export_ruby_env` - If true, values for the environment variables, such as `PATH`, `GEM_HOME`, and `GEM_PATH` will be exported into a file located at `/home/{user}/.etc/ruby_env`. Useful for automating user-specific Ruby commands. Default: true.
- `bashrc_prepend_env` - If true, env variable declarations will be prepended at the beginning of `.bashrc`, instead of appending them. Might be useful for Capistrano shell-less deployments. Default: false.
- `gems` - Gems to be installed, if desired. This is an array of either strings for gem names, or hashes for gem names and versions.
- `apt_packages` - (optional) Dependent OS packages for Ruby. Defaults to `node['app-ror']['ruby']['apt_packages']`.
- `install_git` - Whether to include installation of Git. Default: true.
- `install_yarn` - Whether to include installation of Yarn. Default: true.
- `install_nodejs` - Whether to include installation of NodeJS. Default: true.

#### Properties Wrapped From [Poise-Ruby-Build](https://github.com/poise/poise-ruby-build) Cookbook

- `prefix` - Installation location. Default: `/opt/ruby_build`.
- `install_repo` - Git URI to clone. Default: `https://github.com/sstephenson/ruby-build.git`.
- `install_rev` - Git revision to clone. Default: `master`.

### app_ror_solr

Installs Solr according to the [official guide](https://lucene.apache.org/solr/guide/6_6/taking-solr-to-production.html#taking-solr-to-production).

```ruby
app_ror_solr '6.6.4' do
  solr_port 8000
end
```

#### Actions

- `install` - Install Solr. If Solr already exists, it will be upgraded (default).

#### Properties

- `version` - Version of Solr to install. Defaults to name of resource.
- `file_uri` - If false or not specified, Solr will be downloaded from `http://archive.apache.org/dist/lucene/solr/#{version}/solr-#{version}.tgz`.
- `install_script` - Relative path of install script within the Solr tarball. Defaults to `bin/install_solr_service.sh`.
- `extract_dir` - Where to place Solr files. Defaults to `/opt`.
- `solr_user` - Solr user. Will be created if not existing. Defaults to `solr`.
- `solr_dir` - Solr user files directory. Defaults to `/var/solr`.
- `solr_port` - Solr working port. Defaults to 8983.
- `solr_properties` - (optional) A hash that populates the Solr include file `/etc/default/solr.in.sh`. Note that values here can overwrite those given in `solr_dir` and `solr_port`. For example:
```
app_ror_solr '6.6.4' do
  solr_properties({
    'SOLR_PORT' => 8000,
    'SOLR_HEAP' => '10g',
  })
end
```
- `apt_packages` - (optional) Dependent packages for Solr. Defaults to `node['app-ror']['solr']['apt_packages']`.

### app_ror_manage_puma

Set up Upstart scripts for Puma, taken from this [guide](https://github.com/puma/puma/tree/master/tools/jungle/upstart). Systemd is also supported.

```ruby
app_ror_manage_puma '/var/src/myapp/current' do
  user 'john'
end
```

#### Actions

- `install` - Install and enable the Upstart/Systemd scripts (default)

#### Properties

- `app_dir` - Root path of Rails app. Defaults to name of resource.
- `conf_path` - Path of Puma config file. Defaults to `../../shared/puma.rb`.
- `user` - User to run Puma.
- `group` - Group name of user. Defaults to name of user.
- `env_file` - File containing OS env variables needed for Puma to run. Useful if not using Ruby management tools (rbenv, chruby, etc.). Defaults to: `/home/{user}/.etc/ruby_env`.
- `puma_source` - For providing a custom template.
- `puma_cookbook` - For providing a custom template.

### app_ror_manage_sidekiq

Set up Upstart scripts for Sidekiq, taken from this [guide](https://github.com/mperham/sidekiq/tree/v5.1.3/examples/upstart). Systemd is also supported.

```ruby
app_ror_manage_sidekiq '/var/src/myapp' do
  user 'john'
  environment 'staging'
  dependency({ :systemd => 'redis@test.service' })
end
```

#### Actions

- `install` - Install the Upstart scripts (default)

#### Properties

- `base_dir` - The main (parent) directory of the project. Defaults to name of resource.
- `app_dir` - Location of project. Can be absolute path, or relative to `base_dir`. Defaults to: `current`.
- `log_dir` - Directory where Sidekiq logs are to be stored. Can be absolute path, or relative to `base_dir`. Defaults to: `shared/log`.
- `pidfile_dir` - Directory where Sidekiq writes the pidfile. Can be absolute path, or relative to `base_dir`. Defaults to: `shared/tmp/pids`.
- `conf_path` - Location of Sidekiq config file. Can be absolute path, or relative to `base_dir`. Defaults to: `current/config/sidekiq.yml`.
- `environment` - Sidekiq Ruby environment. Default: `production`.
- `workers` - Number of desired Sidekiq workers. Defaults to 1.
- `user` - User to run Sidekiq.
- `group` - Group name of user. Defaults to name of user.
- `dependency` - Specify here the name of the dependent upstart/systemd service for Sidekiq (e.g. local Redis service). Defaults to: `{ :upstart => false, :systemd => false }` indicating no dependency.
- `env_file` - File containing OS env variables needed for Sidekiq to run. Useful if not using Ruby management tools (rbenv, chruby, etc.). Defaults to: `/home/{user}/.etc/ruby_env`.
- `sidekiq_source` - For providing a custom template.
- `sidekiq_cookbook` - For providing a custom template.
- `workers_source` - (Upstart only) For providing a custom template for worker manager.
- `workers_cookbook` - (Upstart only) For providing a custom template for worker manager.

## License and Authors

Author:: Earth U (<iskitingbords@gmail.com>)

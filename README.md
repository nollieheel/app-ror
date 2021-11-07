# app_ror cookbook

Some cookbook resources to ease setup of Ruby-on-Rails apps.

## Supported Platforms

LTS version of Ubuntu >= 20.04

## Resources

### app_ror_base_dirs

Simply create directories.

```ruby
app_ror_base_dirs '/var/src/myapp' do
  owner 'john'
  sub_dirs ['shared', 'shared/tmp', 'shared/config']
end
```

#### Actions

- `create` - Create the directories (default)

#### Properties

- `base_dir` - The base directory path of project. Defaults to name of resource.
- `owner` - Owner of directories. Default: `ubuntu`.
- `group` - Group name of directories. Defaults to owner name.
- `sub_dirs` - Relative subdirectory/ies that should also be created. Can be an Array. Default: `['shared', 'shared/log']`.

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
- `config` - Logrotate directives. Default:
```
weekly
missingok
rotate 12
compress
delaycompress
notifempty
copytruncate
```
- `logrotate_dir` - Location of logrotate config files. Default: `/etc/logrotate.d`.

### app_ror_ruby

Install Ruby using [Ruby-build](https://github.com/rbenv/ruby-build).

```ruby
app_ror_ruby '2.5.9' do
  user     'john'
  ruby_env {'SOME_RUBY_VAR' => 'foobar'}
end
```

#### Actions

- `install` - Install Ruby (default)

#### Properties

- `version` - Ruby version. Defaults to name of resource.
- `user` - Main user assigned to this installation. Default: `ubuntu`.
- `gem_home` - Default: `/home/{user}/.gem/ruby/{version}`.
- `gem_path` - Default: `{prefix_path}/lib/ruby/gems/{minversion}`, where :minversion is like :version, but the patch number is always `0`. The actual resolved `GEM_PATH` will always also include `GEM_HOME`, so there is no need to include it here.
- `ruby_env` - Additional Ruby environment variables. Default: `{}`.
- `etc_dir` - Default: `/home/{user}/.etc`
- `export_ruby_env` - If true, values for the environment variables, such as `PATH`, `GEM_HOME`, and `GEM_PATH` will be exported into a file located at `{etc_dir}/ruby_env`. Useful for automating user-specific Ruby commands. Default: true.
- `apt_packages` - Dependent OS packages for Ruby. Check resource file for defaults.
- `install_yarn` - Whether to include installation of Yarn. Default: true.
- `install_nodejs` - Whether to include installation of NodeJS. Default: true.

#### Properties Wrapped From [Poise-Ruby-Build](https://github.com/poise/poise-ruby-build) Cookbook

- `prefix_path` - Installation location. Default: `/usr/local/ruby`.
- `ruby_build_git_ref` - Git ref of ruby-build to use. Default: `v20221101`.

### app_ror_manage_puma

Set up Puma systemd unit, taken from this [guide](https://github.com/puma/puma/blob/master/docs/systemd.md).

```ruby
app_ror_manage_puma '/var/src/myapp/current' do
  conf_file 'shared/puma.rb'
end
```

#### Actions

- `install` - Install and enable the systemd unit (default)

#### Properties

- `app_dir` - Root path of Rails app. Defaults to name of resource.
- `conf_file` - Path of Puma config file. Can be relative to dirname of :app_dir. Default: `shared/puma.rb`.
- `user` - User to run Puma. Default: `ubuntu`.
- `env_file` - File containing OS env variables needed for Puma to run. Useful if not using Ruby management tools (rbenv, chruby, etc.). Default: `/home/{user}/.etc/ruby_env`.
- `unit_name` - Default: `puma`.

### app_ror_manage_sidekiq

Set up Sidekiq systemd unit/s, taken from this [guide](https://github.com/mperham/sidekiq/blob/v6.2.2/examples/systemd/sidekiq.service).

```ruby
app_ror_manage_sidekiq '/var/src/myapp/current' do
  environment  'staging'
  processes    3
  dependencies 'redis-server.service'
end
```

#### Actions

- `install` - Install and enable the systemd unit (default)

#### Properties

- `app_dir` - Root path of Rails app. Defaults to name of resource.
- `log_dir` - Directory where Sidekiq logs are to be stored. Can be relative to dirname of `app_dir`. Default: `shared/log`.
- `pidfile_dir` - Directory where Sidekiq writes the pidfile. Can be relative to dirname of `app_dir`. Default: `shared/tmp/pids`.
- `conf_file` - Location of Sidekiq config file. Can be relative to dirname of `app_dir`. Default: `current/config/sidekiq.yml`.
- `environment` - Sidekiq Ruby environment. Default: `production`.
- `user` - User to run Sidekiq. Default: `ubuntu`.
- `group` - Group name of user. Defaults to value of :user.
- `env_file` - File containing OS env variables needed for Sidekiq to run. Useful if not using Ruby management tools (rbenv, chruby, etc.). Defaults to: `/home/{user}/.etc/ruby_env`.
- `processes` - Number of Sidekiq systemd processes to run. Default: `2`.
- `dependencies` - Additional systemd dependencies. E.g. `redis-server.service`. Default: `[]`.
- `unit_name` - Unit name prefix. Default: `sidekiq-`.

## License and Authors

Author:: Earth U (<iskitingbords@gmail.com>)

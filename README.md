# app-ror cookbook

Some cookbook resources to ease setup of Ruby-on-Rails apps.

## Supported Platforms

Ubuntu 14.04

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

Create a swap file and enable it.

```ruby
app_ror_swap '/swapfile' do
  size '4G'
end
```

#### Actions

- `create` - Create the swap file (default)

#### Properties:

- `file` - Name of swapfile. Defaults to name of resource.
- `size` - (optional) Size of swapfile. Defaults to `'4G'`.

### app_ror_base_dirs

Simply create the skeleton directory for your project.

```ruby
app_ror_base_dirs '/var/src/myapp' do
  owner 'john'
end
```

#### Actions

- `create` - Create the directories (default)

#### Properties

- `base_dir` - The directory path. Defaults to name of resource.
- `owner` - Owner of directories.
- `group` - Group name of directories. Defaults to owner name.
- `shared` - (optional) The "shared" directory within your project. Defaults to `'shared'`.

### app_ror_logrotate

Add some logrotate configurations.

```ruby
app_ror_logrotate 'myapp' do
  directory '/var/src/myapp/shared/log/*.log'
end
```

#### Actions

- `create` - Create the logrotate configs (default)

#### Properties

- `filename` - File name of config. Defaults to name of resource.
- `directory` - Path to be logrotated. Can also be an Array.
- `directive` - Logrotate directives. Defaults to:
```
weekly
missingok
rotate 12
compress
delaycompress
notifempty
copytruncate
```
- `config` - If multiple configs are desired, `directory` and `directive` can be ommitted. Instead, use this property and pass an Array of Hashes, each with their own `:filename`, `:directory`, and `:directive` keys. Example:
```
app_ror_logrotate 'foo' do
  config([
    {
      :filename => 'myapp',
      :directory => ['/var/src/myapp/shared/log/*.log', '/var/src/myapp/logs/*']
    },
    {
      :filename => 'anotherapp',
      :directory => '/var/src/anotherapp/logs/*.log'
    }
  ])
end
```

### app_ror_ruby

Install Ruby using RVM.

```ruby
app_ror_ruby '2.5.0' do
  user 'john'
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
- `user` - Main user assigned to this installation.
- `gems` - Gems to be installed, if desired. This is a hash of gem names and versions.
- `apt_packages` - (optional) Dependent packages for Ruby. Defaults to `node['app-ror']['ruby']['apt_packages']`.

### app_ror_solr

Installs Solr according to their [official guide](https://lucene.apache.org/solr/guide/6_6/taking-solr-to-production.html#taking-solr-to-production).

```ruby
app_ror_solr '6.6.4' do
  solr_port '8000'
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
    'SOLR_PORT' => '8000',
    'SOLR_HEAP' => '10g',
  })
end
```
- `apt_packages` - (optional) Dependent packages for Solr. Defaults to `node['app-ror']['solr']['apt_packages']`.

### app_ror_manage_puma

Set up Upstart scripts for Puma, taken from this [guide](https://github.com/puma/puma/tree/master/tools/jungle/upstart).

```ruby
app_ror_manage_puma '/var/src/myapp/current' do
  user 'john'
end
```

#### Actions

- `install` - Install the Upstart scripts (default)

#### Properties

- `roots` - Root path/s of Rails apps. Can also be given as Array. Defaults to name of resource.
- `project_conf_path` - Path of Puma config file to be used for each root. Defaults to `../../shared/puma.rb`.
- `user` - User to run Puma.
- `group` - Group name of user. Defaults to name of user.

### app_ror_manage_sidekiq

Set up Upstart scripts for Sidekiq, taken from this [guide](https://github.com/mperham/sidekiq/tree/v5.1.3/examples/upstart).

```ruby
app_ror_manage_sidekiq '/var/src/myapp' do
  user 'john'
  upstart_starton 'rc'
end
```

#### Actions

- `install` - Install the Upstart scripts (default)

#### Properties

- `base_dir` - The main (parent) directory of the project. Defaults to name of resource.
- `dir_app` - Location of project. Can be absolute path, or relative to `base_dir`. Defaults to: `current`.
- `dir_log` - Directory where Sidekiq logs are to be stored. Can be absolute path, or relative to `base_dir`. Defaults to: `shared/log`.
- `dir_pidfile` - Directory where Sidekiq writes the pidfile. Can be absolute path, or relative to `base_dir`. Defaults to: `shared/tmp/logs`.
- `path_config` - Location of Sidekiq config file. Can be absolute path, or relative to `base_dir`. Defaults to: `current/config/sidekiq.yml`.
- `user` - User to run Sidekiq.
- `group` - Group name of user. Defaults to name of user.
- `num_workers` - Number of desired Sidekiq workers. Defaults to 1.
- `upstart_starton` - Specify here the name of the dependent upstart service for Sidekiq (e.g. redis6379). Defaults to false for no dependency.

## License and Authors

Author:: Earth U (<iskitingbords @ gmail.com>)

# Redis example settings for Upstart.
# The resource app_ror_manage_sidekiq should then be called
# with the property:
#   dependency { :upstart => 'redistest', :systemd => 'redis@test.service' }
default['redisio']['version'] = '4.0.11'
default['redisio']['job_control'] = if node['platform_version'].to_f >= 15.04
  'systemd'
else
  'upstart'
end
default['redisio']['servers'] = [ {
  'name'           => 'test',
  'address'        => '127.0.0.1',
  'port'           => '6379',
  'protected_mode' => 'yes',
  'keepalive'      => '600',
} ]
default['docker_compose']['release'] = '1.23.1'

default['app-ror']['app_env'] = {
  'production' => {
    'MESSAGE'   => '"hellooooo world"',
    'REDIS_URL' => 'redis://localhost:6379'
  }
}

default['mariadb']['install']['type']             = 'package'
default['mariadb']['install']['version']          = '10.2'
default['mariadb']['client']['development_files'] = true
default['mariadb']['use_default_repository']      = true
# Get repos here: https://downloads.mariadb.org/mariadb/repositories/#mirror=utm
default['mariadb']['apt_repository']['base_url'] =
  #'nyc2.mirrors.digitalocean.com/mariadb/repo' # New York
  'sfo1.mirrors.digitalocean.com/mariadb/repo' # San Francisco

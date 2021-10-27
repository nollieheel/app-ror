file '/home/ubuntu/.ssh/self.pem' do
  content <<-EOT
-----BEGIN RSA PRIVATE KEY-----
XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
-----END RSA PRIVATE KEY-----
EOT
  mode 0600
  owner 'ubuntu'
  group 'ubuntu'
end

file '/home/ubuntu/TEST_REPO' do
  content 'https://github.com/nollieheel/olleh-dlrow.git'
  owner 'ubuntu'
end

base_dir = '/var/src/olleh-dlrow'

app_ror_swap '/swapper' do
  size 1024
end

app_ror_base_dirs base_dir do
  owner 'ubuntu'
  sub_dirs ['shared', 'shared/config']
end

app_ror_logrotate 'olleh-dlrow' do
  path "#{base_dir}/shared/log/*.log"
end

app_ror_ruby '2.5.1' do
  user 'ubuntu'
  gem_path '/opt/ruby_build/builds/2.5.1/lib/ruby/gems/2.5.0'
  gems [
#    { gem: 'rails', version: '5.2.1' },
#    { gem: 'sidekiq', version: '5.2.1' }
  ]
end

app_ror_solr '6.6.5'

app_ror_manage_puma "#{base_dir}/current" do
  user 'ubuntu'
end

cookbook_file '/etc/rc.local' do
  mode '0755'
end

# In metadata.rb:
#depends 'redisio', '~> 3.0.0'
#
include_recipe 'redisio'
include_recipe 'redisio::enable'

app_ror_manage_sidekiq base_dir do
  user 'ubuntu'
  workers 2
  dependency(
    :upstart => 'redistest',
    :systemd => 'redis@test.service'
  )
end

#####

# Adding tests for docker
# In metadata.rb:
#depends 'docker', '~> 4.6.7'
#depends 'docker_compose', '~> 0.1.1'

# Install 'docker-ce':
docker_service 'default' do
  install_method 'package'
  action         [:create, :start]
end

include_recipe 'docker_compose::installation'

group 'docker' do
  append  true
  members 'ubuntu'
  action  :manage
end

directory '/home/ubuntu/envs' do
  owner 'ubuntu'
  group 'ubuntu'
end

node['app-ror']['app_env'].each do |env_name, env_vars|
  template "/home/ubuntu/envs/.env.#{env_name}" do
    source '.env.erb'
    owner 'ubuntu'
    group 'ubuntu'
    variables(
      :env_vars => env_vars
    )
  end
end

include_recipe 'mariadb::client'

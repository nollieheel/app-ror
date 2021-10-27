file '/home/ubuntu/TEST_REPO' do
  content 'https://github.com/nollieheel/olleh-dlrow.git'
  owner 'ubuntu'
end

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

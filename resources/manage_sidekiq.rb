#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: app-ror
# Resource:: manage_sidekiq
#
# Copyright (C) 2018, Earth U
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Add config for Sidekiq process manager
# (https://github.com/mperham/sidekiq/tree/v5.1.3/examples/upstart)

# Project properties
property :base_dir, String, name_property: true
property :environment, String, default: 'production'
property :app_dir, String, default: 'current'
property :log_dir, String, default: 'shared/log'
property :pidfile_dir, String, default: 'shared/tmp/pids'
property :conf_path, String, default: 'current/config/sidekiq.yml'
property :workers, [String, Integer], default: 1

# App properties
property :user, String, required: true
property :group, [String, false], default: false
property :env_file, [String, false], default: false
property :dependency, Hash, default: { :upstart => false, :systemd => false }

property :sidekiq_source, [String, false], default: false
property :sidekiq_cookbook, String, default: 'app-ror'
# Only on Upstart:
property :workers_source, String, default: 'workers.conf.erb'
property :workers_cookbook, String, default: 'app-ror'

action :install do
  if not node['platform'] == 'ubuntu'
    Chef::Application.fatal!("#{node['platform']} is not supported")
  end

  env_file = new_resource.env_file ? new_resource.env_file : "/home/#{new_resource.user}/.etc/ruby_env"
  group = new_resource.group ? new_resource.group : new_resource.user

  if node['platform_version'].to_f >= 15.04

    sidekiq_source = new_resource.sidekiq_source ? new_resource.sidekiq_source : 'sidekiq.service.erb'
    template '/etc/systemd/system/sidekiq@.service' do
      source   sidekiq_source
      cookbook new_resource.sidekiq_cookbook
      variables(
        :user        => new_resource.user,
        :group       => group,
        :env_file    => env_file,
        :dependency  => new_resource.dependency,
        :environment => new_resource.environment,
        :base_dir    => new_resource.base_dir,
        :app_dir     => new_resource.app_dir,
        :log_dir     => new_resource.log_dir,
        :pidfile_dir => new_resource.pidfile_dir,
        :conf_path   => new_resource.conf_path,
      )
    end

    new_resource.workers.times do |i|
      execute "enable_sidekiq_#{i}_service" do
        command "systemctl enable sidekiq@#{i}.service"
      end
    end

  elsif node['platform_version'].to_f >= 12.04

    template '/etc/init/workers.conf' do
      source   new_resource.workers_source
      cookbook new_resource.workers_cookbook
      variables(
        :dependency => new_resource.dependency,
        :workers    => new_resource.workers,
      )
    end

    sidekiq_source = new_resource.sidekiq_source ? new_resource.sidekiq_source : 'sidekiq.conf.erb'
    template '/etc/init/sidekiq.conf' do
      source   sidekiq_source
      cookbook new_resource.sidekiq_cookbook
      variables(
        :user        => new_resource.user,
        :group       => group,
        :env_file    => env_file,
        :environment => new_resource.environment,
        :base_dir    => new_resource.base_dir,
        :app_dir     => new_resource.app_dir,
        :log_dir     => new_resource.log_dir,
        :pidfile_dir => new_resource.pidfile_dir,
        :conf_path   => new_resource.conf_path,
      )
    end
  else
    Chef::Application.fatal!("Version #{node['platform_version']} is not supported")
  end
end

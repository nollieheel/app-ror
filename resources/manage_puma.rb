#
# Author:: Earth U (<iskitingbords@gmail.com>)
# Cookbook Name:: app-ror
# Resource:: manage_puma
#
# Copyright (C) 2019, Earth U
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

# Add config for Puma manager.
# (Based on: https://github.com/puma/puma/tree/master/tools/jungle/upstart)

# Project properties
property :app_dir, String, name_property: true
property :conf_path, String, default: '../../shared/puma.rb'

# App properties
property :user, String, required: true
property :group, [String, false], default: false
property :env_file, [String, false], default: false

property :puma_source, [String, false], default: false
property :puma_cookbook, String, default: 'app-ror'

action :install do
  if not node['platform'] == 'ubuntu'
    Chef::Application.fatal!("#{node['platform']} is not supported")
  end

  env_file = new_resource.env_file ? new_resource.env_file : "/home/#{new_resource.user}/.etc/ruby_env"

  if node['platform_version'].to_f >= 15.04

    puma_source = new_resource.puma_source ? new_resource.puma_source : 'puma.service.erb'
    template '/etc/systemd/system/puma.service' do
      source   puma_source
      cookbook new_resource.puma_cookbook
      variables(
        :user      => new_resource.user,
        :env_file  => env_file,
        :app_dir   => new_resource.app_dir,
        :conf_path => new_resource.conf_path
      )
      notifies :run, 'execute[enable_puma_service]', :immediately
    end

    execute 'enable_puma_service' do
      command 'systemctl enable puma.service'
      action  :nothing
    end

  elsif node['platform_version'].to_f >= 12.04

    puma_source = new_resource.puma_source ? new_resource.puma_source : 'puma.conf.erb'
    group = new_resource.group ? new_resource.group : new_resource.user
    template '/etc/init/puma.conf' do
      source   puma_source
      cookbook new_resource.puma_cookbook
      variables(
        :user      => new_resource.user,
        :group     => group,
        :env_file  => env_file,
        :app_dir   => new_resource.app_dir,
        :conf_path => new_resource.conf_path
      )
    end
  else
    Chef::Application.fatal!("Version #{node['platform_version']} is not supported")
  end
end

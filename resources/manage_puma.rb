#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: app-ror
# Resource:: manage_puma
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

# Add config for Jungle, the Puma manager.
# (https://github.com/puma/puma/tree/master/tools/jungle/upstart)

# Project properties
property :roots, [Array, String], name_property: true
property :roots_conf_path, String, default: '/etc/puma.conf'
property :project_conf_path, String, default: '../../shared/puma.rb'

# App properties
property :user, String, required: true
property :group, [String, false], default: false

property :puma_name, String, default: 'puma.conf'
property :puma_source, String, default: 'puma.conf.erb'
property :puma_cookbook, String, default: 'app-ror'
property :puma_manager_name, String, default: 'puma-manager.conf'
property :puma_manager_source, String, default: 'puma-manager.conf.erb'
property :puma_manager_cookbook, String, default: 'app-ror'

action :install do

  template "/etc/init/#{new_resource.puma_manager_name}" do
    source new_resource.puma_manager_source
    cookbook new_resource.puma_manager_cookbook
    variables({ :roots_conf_path => new_resource.roots_conf_path })
  end

  group = new_resource.group ? new_resource.group : new_resource.user
  template "/etc/init/#{new_resource.puma_name}" do
    source new_resource.puma_source
    cookbook new_resource.puma_cookbook
    variables(
      :user => new_resource.user,
      :group => group,
      :project_conf_path => new_resource.project_conf_path
    )
  end

  roots = if new_resource.roots.is_a?(String)
    new_resource.roots.split(',')
  else
    new_resource.roots
  end

  template new_resource.roots_conf_path do
    source 'puma-roots.conf.erb'
    cookbook 'app-ror'
    variables({ :roots => roots })
  end

end

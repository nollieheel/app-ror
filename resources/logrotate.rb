#
# Author:: Earth U (<iskitingbords@gmail.com>)
# Cookbook Name:: app-ror
# Resource:: logrotate
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

# Add logrotate configuration for given directories.

property :filename, String, name_property: true
property :path, [String, Array, false], default: false
property :config, Array, default: %w{
  weekly
  missingok
  rotate\ 12
  compress
  delaycompress
  notifempty
  copytruncate
}
property :configs, [Array, false], default: false
property :logrotate_d, String, default: '/etc/logrotate.d'

action :create do

  if ( new_resource.configs.is_a?(Array) && new_resource.configs.length > 0 )

    new_resource.configs.each do |c|
      config = c.has_key?(:config) ? c[:config] : new_resource.config
      template "#{new_resource.logrotate_d}/#{c[:filename]}" do
        cookbook 'app-ror'
        source   'logrotate.conf.erb'
        variables(
          :path   => c[:path],
          :config => config
        )
      end
    end
  elsif new_resource.path

    template "#{new_resource.logrotate_d}/#{new_resource.filename}" do
      cookbook 'app-ror'
      source   'logrotate.conf.erb'
      variables(
        :path   => new_resource.path,
        :config => new_resource.config
      )
    end
  else
    Chef::Application.fatal!("'configs' or 'path' value must be given")
  end
end

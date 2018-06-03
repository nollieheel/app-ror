#
# Author:: Earth U (<iskitingbords @ gmail.com>)
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
property :config, [Array, false], default: false
property :directory, [String, Array, false], default: false
property :directive, Array, default: %w{
  weekly
  missingok
  rotate\ 12
  compress
  delaycompress
  notifempty
  copytruncate
}
property :logrotate_d, String, default: '/etc/logrotate.d'

action :create do

  if ( new_resource.config && new_resource.config != [] )

    new_resource.config.each do |conf|
      ds = conf.has_key?(:directive) ? conf[:directive] : new_resource.directive
      template "#{new_resource.logrotate_d}/#{conf[:filename]}" do
        cookbook 'app-ror'
        source 'logrotate.conf.erb'
        variables(
          :directory => conf[:directory],
          :directive => ds
        )
      end
    end
  elsif new_resource.directory

    template "#{new_resource.logrotate_d}/#{new_resource.filename}" do
      cookbook 'app-ror'
      source 'logrotate.conf.erb'
      variables(
        :directory => new_resource.directory,
        :directive => new_resource.directive
      )
    end
  else

    Chef::Application.fatal!("'config' or 'directory' value must be given")
  end

end

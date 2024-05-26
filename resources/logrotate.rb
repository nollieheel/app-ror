#
# Cookbook:: app_ror
# Resource:: logrotate
#
# Copyright:: 2024, Earth U
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

cb = 'app_ror'

unified_mode true

property :conf_name, String,
         description: 'Config filename',
         name_property: true

property :path, [String, Array],
         description: 'Location of the log files',
         default: []

property :config, Array,
         description: 'Logrotate settings for this config',
         default: [
           'su ubuntu ubuntu',
           'weekly',
           'missingok',
           'rotate 12',
           'compress',
           'delaycompress',
           'notifempty',
           'copytruncate',
         ]

property :logrotate_dir, String,
         description: 'Location of logrotate config files',
         default: '/etc/logrotate.d'

action :create do
  path = [new_resource.path].flatten

  unless path.empty?
    template "#{new_resource.logrotate_dir}/#{new_resource.conf_name}" do
      cookbook cb
      source   'logrotate.conf.erb'
      variables(
        path:   path,
        config: new_resource.config
      )
    end
  end
end

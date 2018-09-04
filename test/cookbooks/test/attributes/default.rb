#
# Author:: Earth U (<iskitingbords@gmail.com>)
# Cookbook Name:: test
# Attribute:: default
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

default['test']['swapfile'] = '/swapfile'
default['test']['swapsize'] = 1024

default['test']['user'] = 'ubuntu'
default['test']['base_dir'] = '/var/src/test'

default['test']['sub_dirs'] = ['shared', 'shared/config', 'tmp']

default['test']['logrotate_name_1'] = 'test_logrotate1'
default['test']['logrotate_path'] = [
  '/var/src/test/shared/log/*.log',
  '/tmp/*.log'
]
default['test']['logrotate_config'] = %w{ weekly rotate\ 4 }
default['test']['logrotate_configs'] = [
  {
    filename: 'test_logrotate2',
    path: '/some/non/existent/dir/*.log',
    config: %w{ delaycompress copytruncate }
  },
  {
    filename: 'test_logrotate3',
    path: '/another/non/existent/dir/*.log',
    config: %w{ notifempty }
  }
]

default['test']['ruby_ver'] = '2.5.1'
default['test']['ruby_prefix'] = '/opt/ruby_build'
default['test']['ruby_gem_path'] = "#{node['test']['ruby_prefix']}/builds/#{node['test']['ruby_ver']}/lib/ruby/gems/2.5.0"
default['test']['ruby_gems'] = [
  { gem: 'rails', version: '5.2.1' },
  { gem: 'sidekiq', version: '5.2.1' }
]

default['test']['solr_ver'] = '6.6.5'
default['test']['solr_port'] = '8000'

default['test']['sidekiq_workers'] = 2
default['test']['sidekiq_dependency'] = {
  upstart: 'redistest',
  systemd: 'redis@test.service'
}

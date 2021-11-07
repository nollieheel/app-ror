#
# Cookbook:: app_ror
# Resource:: redis
#
# Copyright:: 2022, Earth U
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

# Very simply, install Redis locally using default OS packages.
# Should be useful for testing purposes.

# Package name is 'redis-server' and service name is 'redis-server.service'.

cb = 'app_ror'
unified_mode true

property :install_method, ['default_package'],
         description: 'Installation method. Only supports default_package.',
         default: 'default_package'

property :bind, String,
         description: 'A setting in /etc/redis/redis.conf',
         default: '127.0.0.1'

action :install do
  case new_resource.install_method
  when 'default_package'

    apt_update
    package 'redis-server'

    service 'redis-server' do
      action :nothing
    end

    src = value_for_platform(
      'ubuntu' => {
        '22.04'   => 'redis6.conf.erb',
        '20.04'   => 'redis5.conf.erb',
        'default' => 'Not supported',
      },
      'default' => 'Not supported'
    )

    template '/etc/redis/redis.conf' do
      source   src
      cookbook cb
      variables(
        bind: new_resource.bind
      )
      notifies :restart, 'service[redis-server]'
    end
  else
    log 'Redis installation method not yet supported'
  end
end

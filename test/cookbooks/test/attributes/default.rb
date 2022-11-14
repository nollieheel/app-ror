#
# Cookbook:: test
# Attribute:: default
#
# Copyright:: 2023, Earth U
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

default['test']['base_dir'] = '/var/src/myapp'
default['test']['sub_dirs'] = %w(
  shared
  shared/config
  shared/tmp
  shared/log
)

default['test']['ruby_ver'] = '2.6.10'
default['test']['ruby_env'] = { 'TEST_RUBY_VAR' => 'foobar' }

default['test']['nodejs_ver'] = 'node_16.x'

default['test']['sidekiq_dependencies'] = 'redis-server.service'

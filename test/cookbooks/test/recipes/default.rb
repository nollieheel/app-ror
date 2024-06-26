#
# Cookbook:: test
# Recipe:: default
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

app_ror_base_dirs node['test']['base_dir'] do
  sub_dirs node['test']['sub_dirs']
end

include_recipe 'test::ruby'
include_recipe 'test::nodejs'
include_recipe 'test::manage_puma'
include_recipe 'test::manage_sidekiq'
include_recipe 'test::logrotate'

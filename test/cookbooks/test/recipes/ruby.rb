#
# Author:: Earth U (<iskitingbords@gmail.com>)
# Cookbook Name:: test
# Recipe:: ruby
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

app_ror_ruby node['test']['ruby_ver'] do
  user     node['test']['user']
  prefix   node['test']['ruby_prefix']
  gem_path node['test']['ruby_gem_path']
  gems     node['test']['ruby_gems']
end

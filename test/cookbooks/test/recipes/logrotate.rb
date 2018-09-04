#
# Author:: Earth U (<iskitingbords@gmail.com>)
# Cookbook Name:: test
# Recipe:: logrotate
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

app_ror_logrotate node['test']['logrotate_name_1'] do
  path node['test']['logrotate_path']
  config node['test']['logrotate_config']
end

app_ror_logrotate 'logrotate_test_2' do
  configs node['test']['logrotate_configs']
end

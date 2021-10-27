#
# Author:: Earth U (<iskitingbords@gmail.com>)
# Cookbook Name:: test
# Recipe:: manage_sidekiq
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

app_ror_manage_sidekiq node['test']['base_dir'] do
  user node['test']['user']
  workers node['test']['sidekiq_workers']
  dependency node['test']['sidekiq_dependency']
end

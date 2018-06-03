#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: app-ror
# Resource:: base_dirs
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

# Just set up the base directories needed.

property :base_dir, String, name_property: true
property :shared, String, default: 'shared'
property :owner, String, default: 'ubuntu'
property :group, [String, false], default: false

action :create do

  gr = new_resource.group ? new_resource.group : new_resource.owner
  sh = if new_resource.shared.start_with?('/')
    new_resource.shared
  else
    "#{new_resource.base_dir}/#{new_resource.shared}"
  end

  directory new_resource.base_dir do
    recursive true
    owner new_resource.owner
    group gr
  end

  directory sh do
    recursive true
    owner new_resource.owner
    group gr
  end

end

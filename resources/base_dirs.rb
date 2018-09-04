#
# Author:: Earth U (<iskitingbords@gmail.com>)
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
property :sub_dirs, [String, Array], default: 'shared'
property :owner, String, default: 'ubuntu'
property :group, [String, false], default: false

action_class do
  def create_dir(loc, own, gro)
    directory loc do
      recursive true
      owner     own
      group     gro
    end
  end
end

action :create do

  gr = new_resource.group ? new_resource.group : new_resource.owner

  create_dir(new_resource.base_dir, new_resource.owner, gr)

  if new_resource.sub_dirs.is_a?(Array)
    new_resource.sub_dirs.each do |sub_dir|
      create_dir("#{new_resource.base_dir}/#{sub_dir}", new_resource.owner, gr)
    end
  else
    create_dir("#{new_resource.base_dir}/#{new_resource.sub_dirs}", new_resource.owner, gr)
  end

end

#
# Cookbook:: app_ror
# Resource:: base_dirs
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

unified_mode true

property :base_dir, String,
         description: 'Main directory to be created',
         name_property: true

property :sub_dirs, [String, Array],
         description: 'Relative subdirectory/ies that should also be created',
         default: ['shared', 'shared/log']

property :owner, String,
         description: 'Owner of the directories',
         default: 'ubuntu'

property :group, String,
         description: 'Directory group. Defaults to name of :owner.'

action_class do
  def prop_group
    property_is_set?(:group) ? new_resource.group : new_resource.owner
  end

  def create_dir(loc)
    directory loc do
      recursive true
      owner     new_resource.owner
      group     prop_group
    end
  end
end

action :create do
  create_dir(new_resource.base_dir)

  [new_resource.sub_dirs].flatten.each do |d|
    create_dir("#{new_resource.base_dir}/#{d}")
  end
end

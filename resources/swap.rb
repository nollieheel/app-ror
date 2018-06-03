#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: app-ror
# Resource:: swap
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

# Add a swapfile.

# TODO The guard here could be improved to check also if
# swap is enabled in /etc/fstab or something.

property :file, [String, false], name_property: true
property :size, String, default: '4G'

action :create do

  bash 'enable_swap' do
    code <<-EOF.gsub(/^\s+/, '')
      set -e 
      if [[ ! -f #{new_resource.file} ]] ; then
        fallocate -l #{new_resource.size} #{new_resource.file}
        chmod 600 #{new_resource.file}
        mkswap #{new_resource.file}
        swapon #{new_resource.file}
        echo "#{new_resource.file} none swap sw 0 0" >> /etc/fstab
      fi
    EOF
    only_if { new_resource.file && !::File.exist?(new_resource.file) }
  end

end

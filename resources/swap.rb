#
# Author:: Earth U (<iskitingbords@gmail.com>)
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

property :file, String, name_property: true
property :size, [String, Integer], default: 4096

action :create do

  if Chef::VERSION.to_f >= 14
    log "This custom resource is deprecated in Chef 14. Use the built-in resource 'swap_file', instead." do
      level :warn
    end

    swap_file new_resource.file do
      persist true
      size    new_resource.size
    end

  else
    bash 'enable_swap' do
      code <<-EOF.gsub(/^\s+/, '')
        set -e
        if [[ ! -f #{new_resource.file} ]] ; then
          fallocate -l #{new_resource.size}M #{new_resource.file}
          chmod 600 #{new_resource.file}
          mkswap #{new_resource.file}
          swapon #{new_resource.file}
          echo "#{new_resource.file} none swap sw 0 0" >> /etc/fstab
        fi
      EOF
      not_if { ::File.exist?(new_resource.file) }
    end

  end
end

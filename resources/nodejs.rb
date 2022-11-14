#
# Cookbook:: app_ror
# Resource:: nodejs
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

# Install NodeJS repository for Ubuntu as per:
# https://github.com/nodesource/distributions#manual-installation

unified_mode true

# NOTE: Always check in https://deb.nodesource.com/node_XX.x/dists/ if
#       the version is supported on a particular distribution.
#
#       If using old nodejs versions no longer supported in the
#       desired distro as per the official site above, maybe check
#       the built-in nodejs package of the OS. For example, here are the
#       built-in versions for specific Ubuntu distros:
#           node_10.x on focal (20.04)
#           node_12.x on jammy (22.04)
#
#       To use the above, simply set the :install_repo property to false,
#       in which case, the :version attribute will become useless.
property :version, %w(node_12.x node_14.x node_16.x node_18.x),
         description: 'LTS version string (node_12.x, node_16.x, etc.)',
         name_property: true

property :install_repo, [true, false],
         description: 'Whether or not to install the Nodesource apt repo',
         default: true

property :repo_url_prefix, String,
         description: 'Prefix for the Nodesource apt repo URL string',
         default: 'https://deb.nodesource.com/'

property :key_url, String,
         description: 'Remote URL for Nodesource gpg key',
         default: 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'

property :keyring, String,
         description: 'Local keyring for Nodesource gpg key',
         default: '/usr/share/keyrings/nodesource.gpg'

property :sources_file, String,
         description: 'Location of apt source file',
         default: '/etc/apt/sources.list.d/nodesource.list'

# NOTE: Yarn 1.x must be installed globally at first.
#       Switching to different versions per project (or directory)
#       can be done with:
#           yarn set version [version]
#
#       where [version] can be 'classic' (latest 1.x),
#       'berry' (latest stable 2.x), 'canary' (latest candidate 2.x),
#       or a specific version number.
property :install_yarn, [true, false],
         description: 'Whether to globally install Yarn',
         default: true

action :install do
  apt_update 'app_ror_nodejs' do
    ignore_failure true
  end

  if new_resource.install_repo
    package 'gpg'

    execute 'get_nodesource_key' do
      command "wget --quiet -O - #{new_resource.key_url} | "\
              "gpg --dearmor -o #{new_resource.keyring}"
      not_if  { ::File.exist?(new_resource.keyring) }
    end

    file new_resource.sources_file do
      content  "deb [signed-by=#{new_resource.keyring}] "\
               "#{new_resource.repo_url_prefix}#{new_resource.version} "\
               "#{node['lsb']['codename']} main"
      notifies :update, 'apt_update[app_ror_nodejs_repo]', :immediately
    end

    apt_update 'app_ror_nodejs_repo' do
      action         :nothing
      ignore_failure true
    end

    package 'nodejs'
  else
    package 'nodejs' do
      package_name %w(nodejs npm)
    end
  end

  if new_resource.install_yarn
    include_recipe 'yarn'
  end
end

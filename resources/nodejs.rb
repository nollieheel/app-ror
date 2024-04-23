#
# Cookbook:: app_ror
# Resource:: nodejs
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

# Install NodeJS repository for Ubuntu as per:
# https://github.com/nodesource/distributions/wiki/Repository-Manual-Installation

unified_mode true

# NOTE: Versions and distribution reference:
#         https://github.com/nodesource/distributions/blob/master/README.md
#
#       Version 12.x will use Ubuntu's native repos. There is no longer a
#       distribution for it in nodesource.
#
#       Version 14.x will use the old nodesource distribution.
#
#       All succeeding versions will use the new 'nodistro' nodesource repo.
property :version, %w(node_12.x node_14.x node_16.x node_18.x node_20.x),
         description: 'LTS version string (node_14.x, node_16.x, etc.)',
         name_property: true

# NOTE: Check latest Yarn major versions here:
#         https://yarnpkg.com/getting-started/install
#       Highest possible Yarn versions for each LTS NodeJS version:
#         node_12.x: Yarn 1.22.22
#         node_14.x: Yarn 3.8.2
#         node_16.x: Yarn 3.8.2
#         node_18.x: Yarn 'stable' (4.2.1)
#         node_20.x: Yarn 'stable' (4.2.1)
#
#       Switching Yarn versions in non-corepack yarns:
#         yarn set version [version]
#       Switching Yarn versions with corepack enabled:
#         corepack prepare yarn@[version] --activate
#
#       Latest Yarn major versions:
#         1.22.22
#         2.4.0
#         3.8.2
#         4.2.1
property :install_yarn, [true, false],
         description: 'Whether to globally install Yarn',
         default: true

property :yarn_version, String,
         description: 'Defaults to "latest", which installs the latest '\
                      'possible version of Yarn at the current NodeJS version.',
         default: 'latest'

property :yarn_user, String,
         description: 'Main user for this Yarn instance. Default: "ubuntu".',
         default: 'ubuntu'

action_class do
  def latest_yarn
    case new_resource.version
    when 'node_12.x'
      '1.22.22'
    when 'node_14.x', 'node_16.x'
      '3.8.2'
    when 'node_18.x', 'node_20.x'
      'stable'
    end
  end
end

action :install do
  # Install NodeJS

  if new_resource.version == 'node_12.x'
    apt_update

    package 'nodejs' do
      package_name %w(nodejs npm)
    end

  else
    fin_key = if new_resource.version == 'node_14.x'
                'https://deb.nodesource.com/gpgkey/nodesource.gpg.key'
              else
                'https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key'
              end

    fin_distrib = if new_resource.version == 'node_14.x'
                    node['lsb']['codename']
                  else
                    'nodistro'
                  end

    add_apt 'nodesource' do
      keyserver    false
      key          fin_key
      key_dearmor  true
      uri          "https://deb.nodesource.com/#{new_resource.version}"
      distribution fin_distrib
      components   ['main']
    end

    package 'nodejs'
  end

  # Install Yarn

  if new_resource.install_yarn
    yver = if new_resource.yarn_version == 'latest'
             latest_yarn
           else
             new_resource.yarn_version
           end

    if new_resource.version == 'node_12.x'
      add_apt 'yarn' do
        keyserver    false
        key          'https://dl.yarnpkg.com/debian/pubkey.gpg'
        key_dearmor  true
        uri          'https://dl.yarnpkg.com/debian/'
        distribution 'stable'
        components   ['main']
      end

      package 'yarn'

      execute "/usr/bin/yarn set version #{yver}" do
        user new_resource.yarn_user
        cwd  "/home/#{new_resource.yarn_user}"
      end

    else
      execute '/usr/bin/corepack enable' do
        notifies :run, 'execute[activate_yarn]', :immediately
      end

      execute 'activate_yarn' do
        command "/usr/bin/corepack prepare yarn@#{yver} --activate"
        user    new_resource.yarn_user
        action  :nothing
      end
    end
  end
end

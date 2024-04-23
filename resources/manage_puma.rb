#
# Cookbook:: app_ror
# Resource:: manage_puma
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

require 'pathname'

unified_mode true

# Project properties
property :app_dir, String,
         description: 'Working directory of Ruby project '\
                      'E.g. /var/src/myapp/current',
         name_property: true

property :conf_file, String,
         description: 'Location of Puma config file. '\
                      'Can be relative to dirname of :app_dir.',
         default: 'shared/puma.rb'

# Systemd properties
property :unit_type, %w(simple notify),
         description: 'Using unit type `notify` and watchdog service '\
                      'monitoring is only available for Puma version >=5.1',
         default: 'simple'

property :watchdogsec, Integer,
         description: 'Number of seconds for WatchdogSec. '\
                      'Only useful if :unit_type is notify.',
         callbacks: { 'must be a positive int' => ->(p) { p > 0 } },
         default: 10

property :unit_name, String,
         description: 'Name of the systemd unit',
         default: 'puma'

property :user, String,
         description: 'User that will run the Puma process',
         default: 'ubuntu'

property :env_file, String,
         description: 'EnvironmentFile location assigned to the systemd '\
                      'unit. Defaults to: /home/{user}/.etc/ruby_env if that '\
                      'file exists. Otherwise, no EnvironmentFile will be '\
                      'passed to systemd.'

action_class do
  def prop_conf_file
    if Pathname.new(new_resource.conf_file).absolute?
      new_resource.conf_file
    else
      "#{::File.dirname(new_resource.app_dir)}/#{new_resource.conf_file}"
    end
  end

  def prop_env_file
    f = if property_is_set?(:env_file)
          new_resource.env_file
        else
          "/home/#{new_resource.user}/.etc/ruby_env"
        end

    ::File.exist?(f) ? f : false
  end
end

action :create do
  execstart = "/bin/bash -lc 'bundle exec --keep-file-descriptors "\
              "puma -C #{prop_conf_file}'"

  service = {
    Type:             new_resource.unit_type,
    User:             new_resource.user,
    WorkingDirectory: new_resource.app_dir,
    Restart:          'always',
    ExecStart:        execstart,
  }

  if new_resource.unit_type == 'notify'
    service[:WatchdogSec] = new_resource.watchdogsec
  end

  if prop_env_file
    service[:EnvironmentFile] = prop_env_file
  end

  unit = {
    Unit: {
      Description: "Puma server for #{new_resource.app_dir}. Generated by Chef.",
      After:       'network.target',
    },
    Service: service,
    Install: {
      WantedBy: 'multi-user.target',
    },
  }

  systemd_unit "#{new_resource.unit_name}.service" do
    content unit
    verify  false
    action  [:create, :enable]
  end
end

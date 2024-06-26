#
# Cookbook:: app_ror
# Resource:: manage_sidekiq
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

require 'pathname'

unified_mode true

# Sidekiq systemd config taken from:
# https://github.com/mperham/sidekiq/blob/v5.2.9/examples/systemd/sidekiq.service
# https://github.com/mperham/sidekiq/blob/v6.5.8/examples/systemd/sidekiq.service

# Project properties
property :app_dir, String,
         description: 'Working directory of Ruby project. '\
                      'E.g. /var/src/myapp/current',
         name_property: true

property :environment, String,
         description: 'Sidekiq environment name',
         default: 'production'

property :conf_file, [String, false],
         description: 'Location of Sidekiq config file. '\
                      'If false, --config/-C will not be passed to '\
                      'the sidekiq binary. '\
                      'Can be relative to dirname of :app_dir.',
         default: 'current/config/sidekiq.yml'

property :log_dir, [String, false],
         description: 'Location of logs as passed to the Sidekiq binary. '\
                      'If false, --logfile/-L will not be passed to '\
                      'the sidekiq binary. '\
                      'Can be relative to dirname of :app_dir.',
         default: 'shared/log'

property :pidfile_dir, [String, false],
         description: 'Location of pidfile as passed to the Sidekiq binary. '\
                      'If false, --pidfile/-P will not be passed to '\
                      'the sidekiq binary. '\
                      'Can be relative to dirname of :app_dir.',
         default: 'shared/tmp/pids'

# Systemd properties
#
# NOTE: In >=6.0.6, it might be better not to explicitly pass
#       --config, --logfile, or --pidfile to sidekiq binary.
#       Service type can now also be set to 'notify', which in turn,
#       enables the WatchdogSec option.
property :unit_type, %w(simple notify),
         description: 'Systemd unit type',
         default: 'simple'

property :watchdogsec, Integer,
         description: 'Number of seconds for WatchdogSec. '\
                      'Only useful if :unit_type is notify.',
         callbacks: { 'must be a positive int' => ->(p) { p > 0 } },
         default: 10

property :unit_name, String,
         description: 'Name of the systemd unit. Will be suffixed '\
                      'by processes number.',
         default: 'sidekiq-'

property :user, String,
         description: 'User that will run the Sidekiq process',
         default: 'ubuntu'

property :group, String,
         description: 'Defaults to the name of :user'

property :env_file, String,
         description: 'EnvironmentFile location assigned to the systemd '\
                      'unit. Defaults to: /home/{user}/.etc/ruby_env if that '\
                      'file exists. Otherwise, no EnvironmentFile will be '\
                      'passed to systemd.'

property :dependencies, [String, Array],
         description: 'Additional systemd dependencies, if needed '\
                      '(e.g. redis-server.service)',
         default: []

property :processes, Integer,
         description: 'Number of systemd processes to run. The first process '\
                      'will be called sidekiq-1.service. The second is '\
                      'sidekiq-2.service, and so on.',
         callbacks: { 'must be a positive int' => ->(p) { p > 0 } },
         default: 2

action_class do
  def abs_path(path)
    if Pathname.new(path).absolute?
      path
    else
      "#{::File.dirname(new_resource.app_dir)}/#{path}"
    end
  end

  def prop_conf_file
    if new_resource.conf_file.is_a?(String)
      abs_path(new_resource.conf_file)
    else
      false
    end
  end

  def prop_log_dir
    if new_resource.log_dir.is_a?(String)
      abs_path(new_resource.log_dir)
    else
      false
    end
  end

  def prop_pidfile_dir
    if new_resource.pidfile_dir.is_a?(String)
      abs_path(new_resource.pidfile_dir)
    else
      false
    end
  end

  def prop_group
    property_is_set?(:group) ? new_resource.group : new_resource.user
  end

  def prop_env_file
    f = if property_is_set?(:env_file)
          new_resource.env_file
        else
          "/home/#{new_resource.user}/.etc/ruby_env"
        end

    ::File.exist?(f) ? f : false
  end

  def prop_dependencies
    deps = [new_resource.dependencies].flatten
    deps.empty? ? false : deps
  end
end

action :create do
  desc = "Sidekiq instance %i for #{new_resource.app_dir}. Generated by Chef."

  aft = 'syslog.target network.target'
  if prop_dependencies
    aft << ' ' << prop_dependencies.join(' ')
  end

  exstart = "/bin/bash -lc 'bundle exec sidekiq "\
              "--environment #{new_resource.environment}"
  formatargs = 0
  if prop_conf_file
    exstart << " --config #{prop_conf_file}"
  end
  if prop_pidfile_dir
    exstart << " --pidfile #{prop_pidfile_dir}/#{new_resource.unit_name}%i.pid"
    formatargs += 1
  end
  if prop_log_dir
    exstart << " --logfile #{prop_log_dir}/#{new_resource.unit_name}%i.log"
    formatargs += 1
  end
  exstart << "'"

  ins = { WantedBy: 'multi-user.target' }

  new_resource.processes.times do |p|
    unit = {
      Description: desc % (p + 1),
      After:       aft,
    }

    ps = []
    formatargs.times { ps << (p + 1) }

    service = {
      Type:             new_resource.unit_type,
      User:             new_resource.user,
      Group:            prop_group,
      UMask:            '0002',
      WorkingDirectory: new_resource.app_dir,
      ExecStart:        exstart % ps,
      Environment:      'MALLOC_ARENA_MAX=2',
      RestartSec:       1,
      Restart:          'always',
      StandardOutput:   'journal',
      StandardError:    'journal',
    }

    if new_resource.unit_type == 'notify'
      service[:WatchdogSec] = new_resource.watchdogsec
    end

    if prop_env_file
      service[:EnvironmentFile] = prop_env_file
    end

    systemd_unit "#{new_resource.unit_name}#{p + 1}.service" do
      verify false
      action [:create, :enable]
      content(
        Unit:    unit,
        Service: service,
        Install: ins
      )
    end
  end
end

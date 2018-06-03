#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: app-ror
# Resource:: manage_sidekiq
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

# Add config for Sidekiq process manager
# (https://github.com/mperham/sidekiq/tree/v5.1.3/examples/upstart)

# Project properties
property :base_dir, String, name_property: true
property :environment, String, default: 'production'
property :dir_app, String, default: 'current'
property :dir_log, String, default: 'shared/log'
property :dir_pidfile, String, default: 'shared/tmp/pids'
property :path_config, String, default: 'current/config/sidekiq.yml'

# App properties
property :user, String, required: true
property :group, [String, false], default: false
property :num_workers, [String, Integer], default: 1
property :upstart_starton, [String, false], default: false

property :sidekiq_name, String, default: 'sidekiq.conf'
property :sidekiq_source, String, default: 'sidekiq.conf.erb'
property :sidekiq_cookbook, String, default: 'app-ror'
property :workers_name, String, default: 'workers.conf'
property :workers_source, String, default: 'workers.conf.erb'
property :workers_cookbook, String, default: 'app-ror'

action :install do

  template "/etc/init/#{new_resource.workers_name}" do
    source new_resource.workers_source
    cookbook new_resource.workers_cookbook
    variables(
      :upstart_starton => new_resource.upstart_starton,
      :num_workers     => new_resource.num_workers,
    )
  end

  group = new_resource.group ? new_resource.group : new_resource.user
  template "/etc/init/#{new_resource.sidekiq_name}" do
    source new_resource.sidekiq_source
    cookbook new_resource.sidekiq_cookbook
    variables(
      :user        => new_resource.user,
      :group       => group,
      :environment => new_resource.environment,
      :base_dir    => new_resource.base_dir,
      :dir_app     => new_resource.dir_app,
      :dir_log     => new_resource.dir_log,
      :dir_pidfile => new_resource.dir_pidfile,
      :path_config => new_resource.path_config,
    )
  end

end

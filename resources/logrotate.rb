#
# Cookbook:: app_ror
# Resource:: logrotate
#
# Copyright:: 2021, Earth U

cb = 'app_ror'
unified_mode true

property :conf_name, String,
         description: 'Config filename',
         name_property: true

property :path, [String, Array],
         description: 'Location of the log files',
         default: []

property :config, Array,
         description: 'Logrotate settings for this config'

property :logrotate_dir, String,
         description: 'Default location of logrotate files',
         default: '/etc/logrotate.d'

action_class do
  def prop_path
    [new_resource.path].flatten
  end

  def prop_config
    if property_is_set?(:config)
      new_resource.config
    else
      [
        'weekly',
        'missingok',
        'rotate\ 12',
        'compress',
        'delaycompress',
        'notifempty',
        'copytruncate',
      ]
    end
  end
end

action :create do
  unless prop_path.empty?
    template "#{new_resource.logrotate_dir}/#{new_resource.conf_name}" do
      cookbook cb
      source   'logrotate.conf.erb'
      variables(
        path:   prop_path,
        config: prop_config
      )
    end
  end
end

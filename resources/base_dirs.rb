#
# Cookbook:: app_ror
# Resource:: base_dirs
#
# Copyright:: 2021, Earth U

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

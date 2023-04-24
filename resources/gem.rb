#
# Cookbook:: app_ror
# Resource:: gem
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

unified_mode true

property :name, String,
         description: 'Gem to install',
         name_property: true

property :version, String,
         description: 'Gem version to install'

property :user, String,
         description: 'User who will install the gem',
         default: 'ubuntu'

property :ruby_env_file, String,
         description: 'Defaults to: /home/{user}/.etc/ruby_env'

property :ruby_env, Hash,
         description: 'Additional environment variables for Ruby, if needed',
         default: {}

action_class do
  def user_home
    "/home/#{new_resource.user}"
  end

  def prop_ruby_env_file
    if property_is_set?(:ruby_env_file)
      new_resource.ruby_env_file
    else
      "#{user_home}/.etc/ruby_env"
    end
  end
end

action :install do
  command_str = "gem install #{new_resource.name}"
  if property_is_set?(:version)
    command_str += ":#{new_resource.version}"
  end

  execute command_str do
    cwd   user_home
    user  new_resource.user
    group new_resource.user

    environment lazy {
      renv = {}

      ::File.foreach(prop_ruby_env_file) do |li|
        s = li.split("=", 2).map(&:strip)
        renv[s[0]] = s[1]
      end

      renv.merge(new_resource.ruby_env)
    }
  end
end

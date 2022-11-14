#
# Cookbook:: app_ror
# Resource:: ruby
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

property :version, String,
         description: 'Ruby version to install',
         name_property: true
# From bundler 1, upgrade to specific bundler 2 version:
#   gem install bundler:2.x.y
# To update existing project with lockfile that used bundler 1:
#   bundle _2.x.y_ update --bundler
# or delete Gemfile.lock, then do:
#   bundle _2.x.y_ install

property :user, String,
         description: 'Main user for this installation',
         default: 'ubuntu'

property :gem_home, String,
         description: 'Customize the string written to GEM_HOME. '\
                      'Defaults to: /home/{user}/.gem/ruby/{version}.'

property :gem_path, String,
         description: 'Customize the string written to GEM_PATH. '\
                      'Defaults to: {prefix_path}/lib/ruby/gems/{minversion}, '\
                      'where {minversion} is just like {version}, '\
                      'but the patch number is always 0. '\
                      'Actual resolved GEM_PATH includes the GEM_HOME. '\

property :ruby_env, Hash,
         description: 'Additional environment variables for Ruby, if needed',
         default: {}

property :etc_dir, String,
         description: 'Defaults to: /home/{user}/.etc'

property :export_ruby_env, [true, false],
         description: 'If true, Ruby environment variables (including '\
                      'GEM_HOME and GEM_PATH) will be written into '\
                      '{etc_dir}/ruby_env',
         default: true

property :default_env_path, String,
         description: 'Default PATH value in /etc/environment',
         default: '/usr/local/sbin:/usr/local/bin:'\
                  '/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin'

# Ubuntu 20.04 dependencies as per:
# - https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
# - https://gorails.com/setup/ubuntu/20.04
property :apt_packages, Array,
         description: 'Apt packages to install',
         default: %w(
           autoconf
           bison
           libssl-dev
           libyaml-dev
           libreadline-dev
           libncurses5-dev
           libffi-dev
           libgdbm6
           libgdbm-dev
           libdb-dev
           zlib1g-dev
           libxml2-dev
           libxslt1-dev
           libcurl4-openssl-dev
         )

# Wrapped properties from ruby_build cookbook:
property :prefix_path, String,
         description: 'Location of the Ruby installation',
         default: '/usr/local/ruby'

property :ruby_build_git_ref, String,
         description: 'Git ref of github.com/rbenv/ruby-build repo to download',
         default: 'v20221101'

action_class do
  def user_home
    "/home/#{new_resource.user}"
  end

  def resolved_env
    gem_home = if property_is_set?(:gem_home)
                 new_resource.gem_home
               else
                 "#{user_home}/.gem/ruby/#{new_resource.version}"
               end

    gem_path = if property_is_set?(:gem_path)
                 new_resource.gem_path
               else
                 a = new_resource.version.split('.')
                 "#{new_resource.prefix_path}/lib/ruby/gems/#{a[0]}.#{a[1]}.0"
               end

    {
      'PATH'     => "#{new_resource.prefix_path}/bin:#{new_resource.default_env_path}",
      'GEM_HOME' => gem_home,
      'GEM_PATH' => [gem_home, gem_path].uniq.join(':'),
    }.merge(new_resource.ruby_env)
  end

  def prop_etc_dir
    property_is_set?(:etc_dir) ? new_resource.etc_dir : "#{user_home}/.etc"
  end
end

action :install do
  apt_repository 'git' do
    uri 'ppa:git-core/ppa'
  end

  build_essential

  unless new_resource.apt_packages.empty?
    package 'ror_deps' do
      package_name new_resource.apt_packages
    end
  end

  git_client 'git'

  ruby_build_install 'ruby_build' do
    git_ref new_resource.ruby_build_git_ref
  end

  ruby_build_definition new_resource.version do
    prefix_path new_resource.prefix_path
  end

  directory prop_etc_dir do
    owner     new_resource.user
    recursive true
  end

  etc_env = '/etc/environment'
  etc_env_mark = "#{prop_etc_dir}/etc_environment-updated"

  ruby_block 'update_etc_env' do
    block do
      open(etc_env, 'w') do |f|
        resolved_env.each do |k, v|
          f << "#{k}=#{v}\n"
        end
      end
    end
    only_if  { ::File.exist?(etc_env) }
    notifies :create, "file[#{etc_env_mark}]", :immediately
  end

  file etc_env_mark do
    action  :nothing
    content `date`.to_s
  end

  if new_resource.export_ruby_env
    content_str = resolved_env.map { |k, v| "#{k}=#{v}" }

    file "#{prop_etc_dir}/ruby_env" do
      content content_str.join("\n")
      mode    '0644'
      owner   new_resource.user
    end
  end

  file "#{user_home}/.gemrc" do
    content 'gem: --no-document'
    mode    '0644'
    owner   new_resource.user
    group   new_resource.user
  end
end

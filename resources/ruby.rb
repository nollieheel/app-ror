#
# Author:: Earth U (<iskitingbords@gmail.com>)
# Cookbook Name:: app-ror
# Resource:: ruby
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

property :version, String, name_property: true
property :bundler_version, [String, false], default: false
property :user, String, required: true

property :prefix, String, default: '/opt/ruby_build'
property :install_repo, [String, false], default: false
property :install_rev, [String, false], default: false

property :bin_path, [String, false], default: false
property :gem_home, [String, false], default: false
property :gem_path, [String, false], default: false
property :ruby_env, Hash, default: {}

# etc_dir default value is: /home/{user}/.etc
# export_ruby_env, if true, will write to {etc_dir}/ruby_env
property :etc_dir, [String, false], default: false
property :export_ruby_env, [true, false], default: true

property :apt_packages, Array, default: lazy { node['app-ror']['ruby']['apt_packages'] }
property :gems, Array, default: []

property :install_git, [true, false], default: true
property :install_yarn, [true, false], default: true
property :install_nodejs, [true, false], default: true
property :git_ppa, String, default: 'ppa:git-core/ppa'

action :install do

  # Calculate defaults

  user_home = "/home/#{new_resource.user}"

  bin_path = if new_resource.bin_path
    new_resource.bin_path
  else
    "#{new_resource.prefix}/builds/#{new_resource.version}/bin"
  end

  gem_home = if new_resource.gem_home
    new_resource.gem_home
  else
    "#{user_home}/.gem/ruby/#{new_resource.version}"
  end

  arg_gem_path = if new_resource.gem_path
    new_resource.gem_path
  else
    "#{new_resource.prefix}/builds/#{new_resource.version}/lib/ruby/gems/#{new_resource.version}"
  end
  gem_path = ([ gem_home ] + arg_gem_path.split(':')).uniq.join(':')

  ruby_env = {
    'GEM_HOME' => gem_home,
    'GEM_PATH' => gem_path
  }.merge(new_resource.ruby_env)

  etc_dir = if new_resource.etc_dir
    new_resource.etc_dir
  else
    "#{user_home}/.etc"
  end

  # Dependencies, misc

  apt_update
  if Chef::VERSION.to_f >= 14
    build_essential
  else
    package 'build-essential'
  end

  if new_resource.install_git
    apt_repository 'git' do
      uri          new_resource.git_ppa
      distribution node['lsb']['codename']
    end
    run_context.include_recipe 'git'
  end

  if new_resource.install_nodejs
    run_context.include_recipe 'nodejs'
  end

  if new_resource.install_yarn
    run_context.include_recipe 'yarn'
  end

  package new_resource.apt_packages

  directory etc_dir do
    owner     new_resource.user
    recursive true
  end

  # Install Ruby and gems

  opts = { prefix: new_resource.prefix }
  if new_resource.install_repo
    opts[:install_repo] = new_resource.install_repo
  end
  if new_resource.install_rev
    opts[:install_rev] = new_resource.install_rev
  end
  if new_resource.bundler_version
    opts[:bundler_version] = new_resource.bundler_version
  end
  ruby_runtime new_resource.version do
    provider :ruby_build
    options  opts
  end

  new_resource.gems.each do |g|
    if g.is_a?(String)
      ruby_gem g
    else
      ruby_gem g[:gem] do
        version g[:version]
      end
    end
  end

  execute 'chown_home_bundle' do
    command "chown -R #{new_resource.user} #{user_home}/.bundle"
    only_if { ::Dir.exist?("#{user_home}/.bundle") }
  end

  # Breadcrumbs

  bashrc_mark = "#{etc_dir}/.bashrc-updated"

  ruby_block 'update_bashrc' do
    block do
      open("#{user_home}/.bashrc", 'a') do |f|
        f << "\n"
        { 'PATH' => "#{bin_path}:${PATH}" }.merge(ruby_env).each do |k, v|
          f << "export #{k}=#{v}\n"
        end
      end
    end
    only_if { ::File.exist?("#{user_home}/.bashrc") }
    not_if { ::File.exist?(bashrc_mark) }
    notifies :create, "file[#{bashrc_mark}]", :immediately
  end

  file bashrc_mark do
    action :nothing
    content ( %x( date ) ).to_s
  end

  gemrc_mark = "#{etc_dir}/.gemrc-updated"
  execute 'update_gemrc' do
    command <<~EOT
      echo 'gem: --no-document' >> #{user_home}/.gemrc
    EOT
    notifies :create, "file[#{gemrc_mark}]", :immediately
    not_if { ::File.exist?(gemrc_mark) }
  end

  file gemrc_mark do
    action :nothing
    content ( %x( date ) ).to_s
  end

  if new_resource.export_ruby_env
    ruby_block 'create_ruby_env_file' do
      block do
        open("#{etc_dir}/ruby_env", 'w') do |f|
          {
            'PATH' => "#{bin_path}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
          }.merge(ruby_env).each do |k, v|
            f << "#{k}=#{v}\n"
          end
        end
      end
      notifies :create, "file[#{etc_dir}/ruby_env]", :immediately
    end
    file "#{etc_dir}/ruby_env" do
      owner new_resource.user
    end
  end
end

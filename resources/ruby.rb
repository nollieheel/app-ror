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
property :user, String, required: true

property :prefix, String, default: '/opt/ruby_build'
property :install_repo, [String, false], default: false
property :install_rev, [String, false], default: false

property :bin_path, [String, false], default: false
property :gem_home, [String, false], default: false
property :gem_path, [String, false], default: false

# etc_dir default value is: /home/{user}/.etc
# export_env_file, if true, will write to {etc_dir}/ruby_env
property :etc_dir, [String, false], default: false
property :export_env_file, [true, false], default: true

property :apt_packages, Array, default: lazy { node['app-ror']['ruby']['apt_packages'] }
property :gems, Array, default: []

property :install_git, [true, false], default: true
property :install_yarn, [true, false], default: true
property :install_nodejs, [true, false], default: true
property :git_ppa, String, default: 'ppa:git-core/ppa'

action :install do

  # Calculate defaults

  bin_path = if new_resource.bin_path
    new_resource.bin_path
  else
    "#{new_resource.prefix}/builds/#{new_resource.version}/bin"
  end

  gem_home = if new_resource.gem_home
    new_resource.gem_home
  else
    "/home/#{new_resource.user}/.gem/ruby/#{new_resource.version}"
  end

  arg_gem_path = if new_resource.gem_path
    new_resource.gem_path
  else
    "#{new_resource.prefix}/builds/#{new_resource.version}/lib/ruby/gems/#{new_resource.version}"
  end
  #gem_path = ([ gem_home ] + arg_gem_path.split(':')).map(&:downcase).uniq.join(':')
  gem_path = ([ gem_home ] + arg_gem_path.split(':')).uniq.join(':')

  etc_dir = if new_resource.etc_dir
    new_resource.etc_dir
  else
    "/home/#{new_resource.user}/.etc"
  end

  # Begin process

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

  opts = { prefix: new_resource.prefix }
  if new_resource.install_repo
    opts[:install_repo] = new_resource.install_repo
  end
  if new_resource.install_rev
    opts[:install_rev] = new_resource.install_rev
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

  bashrc_mark = "#{etc_dir}/.bashrc-updated"
  execute 'update_bashrc' do
    command <<~EOT
      echo 'export PATH="#{bin_path}:${PATH}"
      export GEM_HOME="#{gem_home}"
      export GEM_PATH="#{gem_path}"' >> /home/#{new_resource.user}/.bashrc
    EOT
    notifies :create, "file[#{bashrc_mark}]", :immediately
    not_if { ::File.exist?(bashrc_mark) }
  end

  file bashrc_mark do
    action :nothing
    content ( %x( date ) ).to_s
  end

  gemrc_mark = "#{etc_dir}/.gemrc-updated"
  execute 'update_gemrc' do
    command <<~EOT
      echo 'gem: --no-document' >> /home/#{new_resource.user}/.gemrc
    EOT
    notifies :create, "file[#{gemrc_mark}]", :immediately
    not_if { ::File.exist?(gemrc_mark) }
  end

  file gemrc_mark do
    action :nothing
    content ( %x( date ) ).to_s
  end

  if new_resource.export_env_file
    file "#{etc_dir}/ruby_env" do
      content <<~EOT
        PATH=#{bin_path}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        GEM_HOME=#{gem_home}
        GEM_PATH=#{gem_path}
      EOT
      owner new_resource.user
    end
  end
end

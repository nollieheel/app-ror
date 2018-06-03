#
# Author:: Earth U (<iskitingbords @ gmail.com>)
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

# Install Ruby and some gems.
# This whole thing is wrapped in a resource because of a ruby-2.5.0
# bug (mentioned below). Until that bug is resolved, chef_rvm cookbook
# cannot be used normally.

property :version, String, name_property: true
property :user, String, required: true
property :gems, Array, default: []

property :apt_packages, Array, default: lazy { node['app-ror']['ruby']['apt_packages'] }
property :rvm_gpg, String, default: 'D39DC0E3'

property :lsb_codename, String, default: node['lsb']['codename']
property :git_ppa, String, default: 'ppa:git-core/ppa'

action :install do

  # chef_rvm needs this, but has to be done
  # before 'nodejs' or 'yarn'
  execute 'add_gpg_key' do
    command "gpg -k #{new_resource.rvm_gpg} || "\
            "gpg --keyserver hkp://keys.gnupg.net "\
            "--recv-keys #{new_resource.rvm_gpg}"
    user    new_resource.user
  end

  apt_repository 'git' do
    uri          new_resource.git_ppa
    distribution new_resource.lsb_codename
  end

  run_context.include_recipe 'git'
  run_context.include_recipe 'nodejs'
  run_context.include_recipe 'yarn'

  package new_resource.apt_packages

  # Unresolved ruby-2.5.0 bug:
  #   https://github.com/travis-ci/travis-ci/issues/8969
  #
  # The temporary workaround is to `rvm reinstall --disable-binary`.
  # Adding `--disable-binary` to `rvm install` the first time through
  # does not work.
  run_context.include_recipe 'chef_rvm::rvm'
  run_context.include_recipe 'chef_rvm::rubies'

  chef_rvm new_resource.user

  chef_rvm_ruby "#{new_resource.user}:#{new_resource.version}" do
    user    new_resource.user
    version new_resource.version
  end

  rdir = "/home/#{new_resource.user}/.rvm"
  rver = "ruby-#{new_resource.version}"

  execute "reinstall_#{rver}" do
    command "rvm reinstall #{new_resource.version} --disable-binary"
    user    new_resource.user
    not_if  'which gem && gem -v'
    environment(
      'HOME'         => "/home/#{new_resource.user}",
      'GEM_HOME'     => "#{rdir}/gems/#{rver}",
      'GEM_PATH'     => "#{rdir}/gems/#{rver}:#{rdir}/gems/#{rver}@global",
      'MY_RUBY_HOME' => "#{rdir}/rubies/#{rver}",
      'rvm_bin_path' => "#{rdir}/bin",
      'rvm_path'     => rdir,
      'rvm_prefix'   => "/home/#{new_resource.user}",
      'PATH'         => "#{rdir}/gems/#{rver}/bin:"\
        "#{rdir}/gems/#{rver}@global/bin:"\
        "#{rdir}/rubies/#{rver}/bin:/usr/local/sbin:/usr/local/bin:"\
        "/usr/sbin:/usr/bin:/sbin:/bin:#{rdir}/bin:#{rdir}/bin"
    )
  end

  run_context.include_recipe 'chef_rvm::gemsets'
  run_context.include_recipe 'chef_rvm::gems'
  run_context.include_recipe 'chef_rvm::wrappers'
  run_context.include_recipe 'chef_rvm::aliases'

  new_resource.gems.each do |g|
    chef_rvm_gem "install_#{g[:gem]}" do
      gem         g[:gem]
      version     g[:version]
      user        new_resource.user
      ruby_string "#{new_resource.version}@default"
    end
  end

end

#
# Author:: Earth U (<iskitingbords@gmail.com>)
# Cookbook Name:: app-ror
# Resource:: solr
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

# Install Solr via these steps:
# https://lucene.apache.org/solr/guide/6_6/taking-solr-to-production.html#taking-solr-to-production

property :version, String, name_property: true
property :file_uri, [String, false], default: false

property :java_ppa, String, default: 'ppa:openjdk-r/ppa'
property :apt_packages, Array, default: lazy { node['app-ror']['solr']['apt_packages'] }

property :install_script, String, default: 'bin/install_solr_service.sh'
property :extract_dir, String, default: '/opt'
property :solr_user, String, default: 'solr'
property :solr_dir, String, default: '/var/solr'
property :solr_port, [String, Integer], default: '8983'

property :solr_properties, Hash, default: {}

action :install do

  apt_repository 'java' do
    uri new_resource.java_ppa
  end

  package new_resource.apt_packages

  furi = if new_resource.file_uri
    new_resource.file_uri
  else
    "http://archive.apache.org/dist/lucene/solr/#{new_resource.version}/solr-#{new_resource.version}.tgz"
  end

  tmp   = Chef::Config[:file_cache_path]
  fname = ::File.basename(furi)

  remote_file "#{tmp}/#{fname}" do
    source furi
  end

  execute 'extract_solr_install_script' do
    command "cd #{tmp} && tar -xzf #{fname} "\
      "#{::File.basename(fname, ::File.extname(fname))}/#{new_resource.install_script} "\
      "--strip-components=#{new_resource.install_script.split('/').length}"
  end

  opts = " -i #{new_resource.extract_dir} -u #{new_resource.solr_user} "\
         "-d #{new_resource.solr_dir} -p #{new_resource.solr_port}"
  if ::File.exist?('/etc/init.d/solr')
    opts << ' -f'
  end

  execute 'install_solr_via_script' do
    command "bash #{tmp}/#{::File.basename(new_resource.install_script)} "\
      "#{tmp}/#{fname}#{opts}"
  end

  service 'solr' do
    action :stop
  end

  solr_props = {
    'SOLR_PID_DIR'  => new_resource.solr_dir,
    'SOLR_HOME'     => "#{new_resource.solr_dir}/data",
    'LOG4J_PROPS'   => "#{new_resource.solr_dir}/log4j.properties",
    'SOLR_LOGS_DIR' => "#{new_resource.solr_dir}/logs",
    'SOLR_PORT'     => new_resource.solr_port,
  }
  solr_props.merge!(
    new_resource.solr_properties.inject({}) do |acc, (k, v)|
      acc[k.upcase] = v
      acc
    end
  )
  template '/etc/default/solr.in.sh' do
    cookbook 'app-ror'
    owner    'root'
    group    new_resource.solr_user
    mode     '0640'
    notifies :start, 'service[solr]', :immediately
    variables(
      :vars => solr_props
    )
  end

end

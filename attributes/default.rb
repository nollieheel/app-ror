#
# Author:: Earth U (<iskitingbords @ gmail.com>)
# Cookbook Name:: app-ror
# Attribute:: default
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

default['app-ror']['ruby']['apt_packages'] = %w{
  curl zlib1g-dev libssl-dev libreadline-dev libyaml-dev
  libxml2-dev libxslt1-dev libcurl4-openssl-dev
  python-software-properties libffi-dev
}

default['app-ror']['solr']['apt_packages'] = %w{
  openjdk-8-jdk openjdk-8-jre-headless
}

# Redis example settings for Upstart.
# The resource app_ror_manage_sidekiq should then be called
# with the property:
#   upstart_starton 'redisexample'
#default['redisio']['version'] = '4.0.9'
#default['redisio']['job_control'] = 'upstart'
#default['redisio']['servers'] = [ {
#  'name'           => 'example',
#  'address'        => '127.0.0.1',
#  'port'           => '6379',
#  'protected_mode' => 'yes',
#  'keepalive'      => '600',
#} ]

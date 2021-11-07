#
# Cookbook:: app_ror
# Attribute:: default
#
# Copyright:: 2021, Earth U
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

# Valid NodeJS versions are LTS starting from 10: 10.x (EOL), 12.x, 14.x, 16.x
default['nodejs']['repo'] = 'https://deb.nodesource.com/node_16.x'

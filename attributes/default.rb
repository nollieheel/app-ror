#
# Cookbook:: app_ror
# Attribute:: default
#
# Copyright:: 2021, Earth U

# Valid NodeJS versions are LTS starting from 10: 10.x (EOL), 12.x, 14.x, 16.x
default['nodejs']['repo'] = 'https://deb.nodesource.com/node_16.x'

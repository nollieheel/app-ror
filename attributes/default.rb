#
# Cookbook:: app_ror
# Attribute:: default
#
# Copyright:: 2021, Earth U

cb = 'app_ror'

# Ubuntu 20.04 dependencies as per:
# - https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
# - https://gorails.com/setup/ubuntu/20.04
default[cb]['ruby']['apt_packages'] = %w(
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
default[cb]['ruby']['prefix_path'] = '/usr/local/ruby'
default[cb]['ruby']['ruby_build_git_ref'] = 'v20211019' # instead of just 'master'

# Valid NodeJS versions are LTS starting from 10: 10.x (EOL), 12.x, 14.x, 16.x
default['nodejs']['repo'] = 'https://deb.nodesource.com/node_16.x'

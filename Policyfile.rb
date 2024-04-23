# Policyfile.rb - Describe how you want Chef Infra Client to build your system.
#
# For more information on the Policyfile feature, visit
# https://docs.chef.io/policyfile/

# A name that describes what the system you're building with Chef does.
name 'app_ror'

# Where to find external cookbooks:
default_source :supermarket

# run_list: chef-client will run these recipes in the order specified.
run_list 'test::default'

# Specify a custom source for a single cookbook:
cookbook 'app_ror', path: '.'
cookbook 'test', path: 'test/cookbooks/test'
cookbook 'app_add_apt', git: 'https://github.com/nollieheel/app_add_apt.git', tag: 'v1.0.0'

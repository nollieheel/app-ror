# Installed version from test cookbook
describe command('/usr/local/ruby/bin/ruby --version') do
  its('stdout') { should match /2\.6\.10/ }
end

# Installed version from test cookbook
describe command('node --version') do
  its('stdout') { should match /16\.[0-9]{1,3}\.[0-9]{1,3}/ }
end

# Expected version that comes with Ruby 2.6.10
describe command('yarn --version') do
  its('stdout') { should match /1\.22\.19/ }
end

describe command('which git') do
  its('exit_status') { should eq 0 }
end

describe file('/etc/environment') do
  its('content') { should match /GEM_HOME/ }
  its('content') { should match /GEM_PATH/ }
  its('content') { should match /TEST_RUBY_VAR/ }
end

describe file('/home/ubuntu/.etc/ruby_env') do
  its('content') { should match /GEM_HOME/ }
  its('content') { should match /GEM_PATH/ }
  its('content') { should match /TEST_RUBY_VAR/ }
end

# Default resource values and custom working dir from test cookbook
describe file('/etc/systemd/system/puma.service') do
  its('content') { should match %r{puma -C /var/src/myapp/shared/puma\.rb} }
  its('content') { should match /User=ubuntu/ }
  its('content') { should match %r{EnvironmentFile=/home/ubuntu/\.etc/ruby_env} }
end

describe systemd_service('puma.service') do
  it { should be_installed }
  it { should be_enabled }
end

# Default resource values and custom working dir from test cookbook
describe file('/etc/systemd/system/sidekiq-1.service') do
  its('content') { should match /bundle exec sidekiq/ }
  its('content') { should match %r{--config /var/src/myapp/current/config/sidekiq\.yml} }
  its('content') { should match %r{--pidfile /var/src/myapp/shared/tmp/pids/sidekiq-1\.pid} }
  its('content') { should match %r{--logfile /var/src/myapp/shared/log/sidekiq-1\.log} }
  its('content') { should match /User=ubuntu/ }
  its('content') { should match /Group=ubuntu/ }
  its('content') { should match %r{EnvironmentFile=/home/ubuntu/\.etc/ruby_env} }
end

describe service('sidekiq-1.service') do
  it { should be_installed }
  it { should be_enabled }
end

describe file('/etc/systemd/system/sidekiq-2.service') do
  its('content') { should match /bundle exec sidekiq/ }
  its('content') { should match %r{--config /var/src/myapp/current/config/sidekiq\.yml} }
  its('content') { should match %r{--pidfile /var/src/myapp/shared/tmp/pids/sidekiq-2\.pid} }
  its('content') { should match %r{--logfile /var/src/myapp/shared/log/sidekiq-2\.log} }
  its('content') { should match /User=ubuntu/ }
  its('content') { should match /Group=ubuntu/ }
  its('content') { should match %r{EnvironmentFile=/home/ubuntu/\.etc/ruby_env} }
end

describe service('sidekiq-2.service') do
  it { should be_installed }
  it { should be_enabled }
end

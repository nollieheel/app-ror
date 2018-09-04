if os.release.to_f >= 15.04

  describe file('/etc/systemd/system/sidekiq@.service') do
    it { should exist }
    its('content') { should match /User=ubuntu/ }
    its('content') { should match /Group=ubuntu/ }
    its('content') { should match /WorkingDirectory=\/var\/src\/test\/current/ }
    its('content') { should match /--environment production/ }
    its('content') { should match /--logfile \/var\/src\/test\/shared\/log\/sidekiq\.log/ }
    its('content') { should match /--pidfile \/var\/src\/test\/shared\/tmp\/pids\/sidekiq-\%i\.pid/ }
    its('content') { should match /--config \/var\/src\/test\/current\/config\/sidekiq.yml/ }
  end

  describe service('sidekiq@0.service') do
    it { should be_installed }
    it { should be_enabled }
  end

  describe service('sidekiq@1.service') do
    it { should be_installed }
    it { should be_enabled }
  end

elsif os.release.to_f >= 12.04

  describe file('/etc/init/workers.conf') do
    it { should exist }
    its('content') { should match /NUM_WORKERS=2/ }
    its('content') { should match /start on started redistest/ }
  end

  describe service('workers') do
    it { should be_installed }
    it { should be_enabled }
  end

  describe file('/etc/init/sidekiq.conf') do
    it { should exist }
    its('content') { should match /setuid ubuntu/ }
    its('content') { should match /setgid ubuntu/ }
    its('content') { should match /environment=production/ }
    its('content') { should match /app_dir=\/var\/src\/test\/current/ }
    its('content') { should match /log_dir=\/var\/src\/test\/shared\/log/ }
    its('content') { should match /pidfile_dir=\/var\/src\/test\/shared\/tmp\/pids/ }
    its('content') { should match /conf_path=\/var\/src\/test\/current\/config\/sidekiq.yml/ }
  end
end

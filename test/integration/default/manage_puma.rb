if os.release.to_f >= 15.04

  describe file('/etc/systemd/system/puma.service') do
    it { should exist }
    its('content') { should match /puma -C \.\.\/\.\.\/shared\/puma\.rb/ }
    its('content') { should match /User=ubuntu/ }
  end
  sname = 'puma.service'

elsif os.release.to_f >= 12.04

  describe file('/etc/init/puma.conf') do
    it { should exist }
    its('content') { should match /puma -C \.\.\/\.\.\/shared\/puma\.rb/ }
    its('content') { should match /setuid ubuntu/ }
    its('content') { should match /setgid ubuntu/ }
  end
  sname = 'puma'
end

describe service(sname) do
  it { should be_installed }
  it { should be_enabled }
end

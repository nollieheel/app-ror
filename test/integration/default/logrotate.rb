describe file('/etc/logrotate.d/test_logrotate') do
  its('sha256sum') { should eq '5060143926057300ab5427765e620c5b78627148092341d9d9cb38144b9bddcd' }
end

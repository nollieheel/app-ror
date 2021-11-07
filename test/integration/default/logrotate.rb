describe file('/etc/logrotate.d/test_logrotate') do
  its('sha256sum') { should eq 'c986873c1fa0c50ef1785f17e5f19b8761d526ffe7781d76b530c009a9c6d248' }
end

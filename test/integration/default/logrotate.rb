# test_logrotate1 content should be:
# /var/src/test/shared/log/*.log
# /tmp/*.log
# {
#     weekly
#     rotate 4
# }
describe file('/etc/logrotate.d/test_logrotate1') do
  it { should exist }
  its('sha256sum') { should eq '2dc89ee20c471e3a6a9bef3648d61dee719ff7b8cdc741d20e552c796e9241ae' }
  its('owner') { should eq 'root' }
end

# test_logrotate2 content should be:
# /some/non/existent/dir/*.log {
#     delaycompress
#     copytruncate
# }
describe file('/etc/logrotate.d/test_logrotate2') do
  it { should exist }
  its('sha256sum') { should eq 'a02a76785e0b5dd455ab921fceb18a37e389e859881252b37dc58c84a04db076' }
  its('owner') { should eq 'root' }
end

# test_logrotate3 content should be:
# /another/non/existent/dir/*.log {
#     notifempty
# }
describe file('/etc/logrotate.d/test_logrotate3') do
  it { should exist }
  its('sha256sum') { should eq '83c51a256584b802f6630c76657752cf0691ae705ab3b30ead643c667091016a' }
  its('owner') { should eq 'root' }
end

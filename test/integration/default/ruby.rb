bin_dir = '/opt/ruby_build/builds/2.5.1/bin'

describe command("#{bin_dir}/ruby --version") do
  its('stdout') { should match /2\.5\.1/ }
end

describe command('which git') do
  its('exit_status') { should eq 0 }
end

describe command('which node') do
  its('exit_status') { should eq 0 }
end

describe command('which yarn') do
  its('exit_status') { should eq 0 }
end

describe command("#{bin_dir}/rails --version") do
  its('stdout') { should match /5\.2\.1/ }
end

describe command("#{bin_dir}/sidekiq --version") do
  its('stdout') { should match /5\.2\.1/ }
end

describe file('/swapfile') do
  its('mode') { should cmp '0600' }
end

describe etc_fstab.where { device_name == '/swapfile' } do
  its('file_system_type') { should cmp 'swap' }
end

describe command('swapon -s') do
  its('stdout') { should match /\/swapfile/ }
end

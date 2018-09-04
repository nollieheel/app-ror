describe user('solr') do
  it { should exist }
end

describe file('/opt/solr/bin/solr') do
  it { should exist }
end

describe directory('/var/solr') do
  it { should exist }
  its('owner') { should eq 'solr' }
end

describe port(8000) do
  it { should be_listening }
  its('processes') { should include 'java' }
end

app_ror_solr '6.6.6' do
  solr_port 8080
  solr_properties(
    'SOLR_HEAP' => '512m',
    'SOLR_HOST' => '0.0.0.0',
  )
end

#a = 'this string must be prepended'
#f = '/home/ubuntu/foo'
#f2 = '/home/ubuntu/foo2'
#
#ruby_block 'do the thing' do
#  block do
#    File.open(f2, 'w') do |x|
#      x.puts a
#      File.foreach(f) do |y|
#        x.puts y
#      end
#    end
#
#    File.rename(f, f + '.old')
#    File.rename(f2, f)
#  end
#end

#vars = node[cookbook_name]

#app_ror_ruby vars['ver'] do
#  user            vars['user']
#  gem_path        vars['gem_path']
#  gems            vars['gems']
#  bundler_version vars['bundler_ver']
#  bashrc_prepend_env true
#end

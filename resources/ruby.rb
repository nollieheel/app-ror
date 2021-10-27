#
# Cookbook:: app_ror
# Resource:: ruby
#
# Copyright:: 2021, Earth U

cb = 'app_ror'
unified_mode true

property :version, String,
         description: 'Ruby version to install',
         name_property: true

property :user, String,
         description: 'Main user for this installation',
         default: 'ubuntu'

property :ruby_bin_path, String,
         description: 'Location of Ruby installation binaries. '\
                      'Defaults to: {prefix_path}/bin'

property :gem_home, String,
         description: 'Defaults to: /home/{user}/.gem/ruby/{version}'

property :gem_path, String,
         description: 'Defaults to: {prefix_path}/lib/ruby/gems/{version}. '\
                      'Actual resolved :gem_path includes the :gem_home. '\
                      'The version suffix must be manually verified because '\
                      'patch values in the version number does not actually '\
                      'modify this suffix in practice.'

property :ruby_env, Hash,
         description: 'Additional environment variables for Ruby, if needed',
         default: {}

property :export_ruby_env, [true, false],
         description: 'If true, Ruby environment variables (including '\
                      'GEM_HOME and GEM_PATH) will be written into '\
                      '{etc_dir}/ruby_env',
         default: true

property :etc_dir, String,
         description: 'Defaults to: /home/{user}/.etc'

property :bashrc_prepend_env, [true, false],
         description: 'If true, env variable declarations will be prepended '\
                      'at the beginning of ~/.bashrc, instead of appending '\
                      'them. Might be useful for Capistrano shell-less '\
                      'deployments.',
         default: false

property :apt_packages, Array,
         description: 'Apt packages to install',
         default: node[cb]['ruby']['apt_packages']

property :install_nodejs, [true, false],
         description: 'Whether to install NodeJS',
         default: true

property :install_yarn, [true, false],
         description: 'Whether to install Yarn',
         default: true

# Wrapped properties from ruby_build cookbook:
property :prefix_path, String,
         description: 'Location of the Ruby installation',
         default: node[cb]['ruby']['prefix_path']

property :ruby_build_git_ref, String,
         description: 'Git ref of ruby_build repo to download',
         default: node[cb]['ruby']['ruby_build_git_ref']

action_class do
  def user_home
    "/home/#{new_resource.user}"
  end

  def prop_ruby_bin_path
    if property_is_set?(:ruby_bin_path)
      new_resource.ruby_bin_path
    else
      "#{new_resource.prefix_path}/bin"
    end
  end

  def prop_gem_home
    if property_is_set?(:gem_home)
      new_resource.gem_home
    else
      "#{user_home}/.gem/ruby/#{new_resource.version}"
    end
  end

  def prop_gem_path
    if property_is_set?(:gem_path)
      new_resource.gem_path
    else
      "#{new_resource.prefix_path}/lib/ruby/gems/#{new_resource.version}"
    end
  end

  def resolved_gem_path
    [prop_gem_home, prop_gem_path].uniq.join(':')
  end

  def resolved_ruby_env
    {
      'GEM_HOME' => prop_gem_home,
      'GEM_PATH' => resolved_gem_path,
    }.merge(new_resource.ruby_env)
  end

  def prop_etc_dir
    property_is_set?(:etc_dir) ? new_resource.etc_dir : "#{user_home}/.etc"
  end
end

action :install do
  apt_repository 'git' do
    uri 'ppa:git-core/ppa'
  end

  build_essential

  unless new_resource.apt_packages.empty?
    package 'ror_deps' do
      package_name new_resource.apt_packages
    end
  end

  git_client 'git'

  ruby_build_install 'ruby_build' do
    git_ref new_resource.ruby_build_git_ref
  end

  ruby_build_definition new_resource.version do
    prefix_path new_resource.prefix_path
  end

  if new_resource.install_nodejs
    include_recipe 'nodejs'
  end

  if new_resource.install_yarn
    # Yarn 1.x is must be installed globally.
    # Migrating to >= 2.x is then on a per-project basis.
    include_recipe 'yarn'
  end

  directory prop_etc_dir do
    owner     new_resource.user
    recursive true
  end

  bashrc = "#{user_home}/.bashrc"
  bashrc_mark = "#{prop_etc_dir}/.bashrc-updated"
  bashrc_tmp = "#{user_home}/.bashrc.tmp"

  ruby_block 'update_bashrc' do
    block do
      bash_vars = {
        'PATH' => "#{prop_ruby_bin_path}:${PATH}",
      }.merge(resolved_ruby_env)

      if new_resource.bashrc_prepend_env

        open(bashrc_tmp, 'w') do |f|
          f << "###\n# Prepended to ~/.bashrc by Chef:\n###\n"
          bash_vars.each do |k, v|
            f << "export #{k}=#{v}\n"
          end
          f << "###\n"

          ::File.foreach(bashrc) do |g|
            f << g
          end
        end
        ::File.rename(bashrc, "#{prop_etc_dir}/.bashrc.orig")
        ::File.rename(bashrc_tmp, bashrc)
      else

        open(bashrc, 'a') do |f|
          f << "\n###\n# Added by Chef:\n###\n"
          bash_vars.each do |k, v|
            f << "export #{k}=#{v}\n"
          end
          f << "###\n"
        end
      end
    end
    only_if  { ::File.exist?(bashrc) }
    not_if   { ::File.exist?(bashrc_mark) }
    notifies :create, "file[#{bashrc_mark}]", :immediately
  end

  file bashrc_mark do
    action  :nothing
    content `date`.to_s
  end

  file bashrc do
    mode  '0644'
    owner new_resource.user
    group new_resource.user
  end

  file "#{user_home}/.gemrc" do
    content 'gem: --no-document'
    mode    '0644'
    owner   new_resource.user
    group   new_resource.user
  end

  if new_resource.export_ruby_env
    env_vars_str = {
      'PATH' => "#{prop_ruby_bin_path}:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
    }.merge(resolved_ruby_env).map { |k, v| "#{k}=#{v}" }

    file "#{prop_etc_dir}/ruby_env" do
      content env_vars_str.join("\n")
      mode    '0644'
      owner   new_resource.user
    end
  end
end

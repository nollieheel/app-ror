#
# Cookbook:: app_ror
# Resource:: ruby
#
# Copyright:: 2021, Earth U

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

# Prepending the environment variables in .bashrc allows them to be
# executed _before_ this section:
#   case $- in
#       *i*) ;;
#         *) return;;
#   esac
# which causes the rest of the file to be bypassed when deploying with
# Capistrano, due to the fact that Capistrano uses a non-interactive shell.
property :bashrc_prepend_env, [true, false],
         description: 'If true, env variable declarations will be prepended '\
                      'at the beginning of ~/.bashrc, instead of appending '\
                      'them. Might be useful for Capistrano shell-less '\
                      'deployments.',
         default: false,
         deprecated: 'The property bashrc_prepend_env has been deprecated '\
                     'and no longer does anything. Generated Ruby env '\
                     'variables will now always be available to both '\
                     'interactive and non-interactive shells.'

# Ubuntu 20.04 dependencies as per:
# - https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
# - https://gorails.com/setup/ubuntu/20.04
property :apt_packages, Array,
         description: 'Apt packages to install',
         default: %w(
           autoconf
           bison
           libssl-dev
           libyaml-dev
           libreadline-dev
           libncurses5-dev
           libffi-dev
           libgdbm6
           libgdbm-dev
           libdb-dev
           zlib1g-dev
           libxml2-dev
           libxslt1-dev
           libcurl4-openssl-dev
         )

property :install_nodejs, [true, false],
         description: 'Whether to install NodeJS',
         default: true

# Yarn 1.x must be installed globally.
# Migrating to >= 2.x is then on a per-project basis.
property :install_yarn, [true, false],
         description: 'Whether to install Yarn',
         default: true

property :default_env_path, String,
         description: 'Default PATH variable in /etc/environment',
         default: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'

# Wrapped properties from ruby_build cookbook:
property :prefix_path, String,
         description: 'Location of the Ruby installation',
         default: '/usr/local/ruby'

property :ruby_build_git_ref, String,
         description: 'Git ref of ruby_build repo to download',
         default: 'v20211019'

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

  def resolved_env
    {
      'PATH' => "#{prop_ruby_bin_path}:#{new_resource.default_env_path}",
    }.merge(resolved_ruby_env)
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
    include_recipe 'yarn'
  end

  directory prop_etc_dir do
    owner     new_resource.user
    recursive true
  end

  etc_env = '/etc/environment'
  etc_env_mark = "#{prop_etc_dir}/etc_environment-updated"

  ruby_block 'update_etc_env' do
    block do
      open(etc_env, 'a') do |f|
        resolved_env.each do |k, v|
          f << "#{k}=#{v}\n"
        end
      end
    end
    only_if  { ::File.exist?(etc_env) }
    not_if   { ::File.exist?(etc_env_mark) }
    notifies :create, "file[#{etc_env_mark}]", :immediately
  end

  file etc_env_mark do
    action  :nothing
    content `date`.to_s
  end

  if new_resource.export_ruby_env
    content_str = resolved_env.map { |k, v| "#{k}=#{v}" }

    file "#{prop_etc_dir}/ruby_env" do
      content content_str.join("\n")
      mode    '0644'
      owner   new_resource.user
    end
  end

  file "#{user_home}/.gemrc" do
    content 'gem: --no-document'
    mode    '0644'
    owner   new_resource.user
    group   new_resource.user
  end
end

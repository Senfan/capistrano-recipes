# config valid only for Capistrano 3.1
lock '3.2.1'

user="deploy"
HOME="/home/#{user}"
ruby_version="2.1.2"
set :host, "10.110.125.211"

set :application, 'test'
set :user, 'deploy'
set :scm, :git
set :repo_url, 'https://github.com/teddy-hoo/test.git'
set :deploy_to, "/home/#{user}/webapp"
set :pty, true

set :stage, :staging
set :branch, "master"
role :web, %w{deploy@10.110.125.211}

set :bundle_roles, :all
set :bundle_servers, -> { release_roles(fetch(:bundle_roles)) }
set :bundle_binstubs, -> { shared_path.join('bin') }
set :bundle_gemfile, -> { release_path.join('Gemfile') }
set :bundle_path, -> { shared_path.join('bundle') }
set :bundle_without, %w{development test}.join(' ')
set :bundle_flags, '--no-deployment'
set :bundle_env_variables, {}

#set stage
#set :stage, 'production'

#set rbenv
#set :rbenv_type, :user # or :system, depends on your rbenv setup
#set :rbenv_ruby, '2.1.2'
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{#fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
#set :rbenv_map_bins, %w{rake gem bundle ruby rails}
#set :rbenv_roles, :all # default value

namespace :env do
  desc "environment setup"
  task :setup do
    on roles(:web) do
      pkgs = %w(git gcc make zlib1g-dev libxml2-dev libxml2 libxslt1.1 libxslt1-dev openssl libssl-dev g++ unzip sqlite3 libsqlite3-dev libpq-dev ntp libpcre3 libpcre3-dev)
      execute "sudo apt-get -y update"
      pkgs.each do |pkg|
        puts %{pkg}
        execute "sudo apt-get -y install #{pkg}"
      end
    end
  end
end

namespace :deploy do

  #before "ruby:setup", "env:setup"
  before "deploy",  "ruby:setup"
  desc 'start appliction'
  task :start do
    on roles(:web) do
      execute "$ruby #{release_path}/server.rb"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:web) do
      #execute "pkill ruby"
      #execute "ruby #{release_path}/server.rb"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

namespace :ruby do

  desc "install rbenv, ruby, and bundler"
  task :setup do
    on roles(:web) do
      test=capture("echo 'true'")
      if capture("if [ -d ~/.rbenv ]; then echo 'true'; fi") == ''
        execute "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv"
      else
        execute "cd ~/.rbenv && git pull"
      end
      #if capture("if grep rbenv ~/.bashrc; then echo 'true'; fi") == ''
        execute "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~/.bashrc"
        execute "echo 'eval \"$(rbenv init -)\"' >> ~/.bashrc"
        execute "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~/.bash_profile"
        execute "echo 'eval \"$(rbenv init -)\"' >> ~/.bash_profile"
      #end
      execute "echo $PATH"
      execute "source ~/.bash_profile"
      execute "echo $PATH"
      if capture("if [ -d ~/.rbenv/plugins/ruby-build ]; then echo 'true'; fi") == ''
        execute "git clone https://github.com/sstephenson/ruby-build ~/.rbenv/plugins/ruby-build"
        execute "rbenv rehash"
      else
        execute "cd ~/.rbenv/plugins/ruby-build && git pull"
        execute "rbenv rehash"
      end
      if capture("if [ -d ~/.rbenv/versions/#{ruby_version} ]; then echo 'true'; fi") == ''
        execute "rbenv install #{ruby_version}"
        execute "rbenv global #{ruby_version}"
        execute "rbenv rehash"
      end
      execute "gem install bundler"
      execute "rbenv rehash"
    end
  end
end

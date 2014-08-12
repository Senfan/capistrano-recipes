# config valid only for Capistrano 3.1
lock '3.2.1'
require 'json'

file = File.read('./config/server.json')
data = JSON.parse(file)

puts data
puts data['server']
puts data['server'][0]
puts data['server'][0]['host']

host = data['server'][0]['host']
user = data['server'][0]['username']
git_repo="https://github.com/teddy-hoo/test.git"
ruby_version="2.1.2"

if("#{ruby_version}".empty?)
  set :ruby_version, "2.1.2"
end

set :application, 'test'
set :user, "#{user}"
set :scm, :git
set :repo_url, "#{git_repo}"
set :deploy_to, "/home/#{user}/webapp"
set :pty, true

set :stage, :staging
set :branch, "master"
server "#{host}", roles: [:web], user: "#{user}"

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
#set :rbenv_ruby, "#{fetch(:ruby_version)}"
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

namespace :ruby do

  desc "install rbenv, ruby, and bundler"
  task :setup do
    on roles(:web) do
      if capture("if [ -d ~/.rbenv ]; then echo 'true'; fi") == ''
        execute "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv"
      else
        execute "cd ~/.rbenv && git pull"
      end
      if capture("if grep rbenv ~/.bashrc; then echo 'true'; fi") == ''
        execute "echo 'eval \"$(rbenv init -)\"' | cat - ~/.bashrc > tmp"
        execute "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' | cat - tmp > tmp1"
        execute "mv ~/tmp1 ~/.bashrc"
        execute "rm ~/tmp"
        execute ". ~/.bashrc"
      end
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

namespace :github do

  desc "configure github environment"
  task :setup do
    on roles(:web) do
      ask(:option, "do you want to config github?(Y)")
      if("#{fetch(:option)}" == "Y")
        ask(:email, "input email address: ")
        file = "~/.ssh/id_rsa"
        public_file = "#{file}.pub"
        execute "git config --global core.editor 'vi'"
        execute "git config --global user.email '#{fetch(:email)}'"
        if capture("if [ -f #{file} ]; then echo 'true'; fi") == ''
          execute "ssh-keygen -q -t rsa -C '#{fetch(:email)}' -N '' -f '#{file}' "
        end
        key = capture "cat #{public_file}"
        ask(:username, "input github username: ")
        ask(:password, "input github password: ")
        github = Github.new( login: username, password: password )
        github.users.keys.create( title: "capistrano generated", key: key )
      end
    end
  end

end


namespace :deploy do

  before "ruby:setup", "env:setup"
  before "deploy", "ruby:setup"
  #after "deploy", "github:setup"
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

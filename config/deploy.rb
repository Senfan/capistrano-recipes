# config valid only for Capistrano 3.1
lock '3.2.1'
require 'json'


file = File.read('./config/server.json')
data = JSON.parse(file)

host = data['server']['deploy']['host']
user = data['server']['deploy']['username']
git_repo=data["git_repo"]

if host == ''
  ask(:hostad, "input host address: ")
end
host = "#{fetch(:hostad)}"

if user == ''
  ask(:username, 'input username: ')
end
user = "#{fetch(:username)}"

if git_repo == ''
  ask(:gitrepo, 'input username: ')
end
git_repo = "#{fetch(:gitrepo)}"

server "#{host}", roles: [:web], user: "#{user}"

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
      ask(:email, "input email address: ")
      execute "printf 'Host github.com \\n\\t User git" +
              " \\n\\t Hostname ssh.github.com" +
              " \\n\\t PreferredAuthentications publickey" +
              " \\n\\t IdentityFile ~/.ssh/id_rsa" +
              " \\n\\t Port 443\\n' > ~/.ssh/config"
      file = "~/.ssh/id_rsa"
      public_file = "#{file}.pub"
      execute "git config --global user.email '#{fetch(:email)}'"
      if capture("if [ -f #{file} ]; then echo 'true'; fi") == ''
        execute "ssh-keygen -q -t rsa -C '#{fetch(:email)}' -N '' -f '~/ssh/id_rsa' "
      end
      key = capture("cat #{public_file}")
      ask(:username, "input github username: ")
      ask(:password, "input github password: ")
      github = Github.new( login: "#{fetch(:username)}", password: "#{fetch(:password)}" )
      github.users.keys.create( title: "capistrano generated", key: key )
    end
  end
 
end

namespace :bundle do
  desc 'run bundle install'
  task :install do
    on roles(:web) do
      execute "cd #{release_path} && bundle install"
    end
  end
end

namespace :deploy do

  #before "github:setup", "env:setup"
  #before "ruby:setup", "github:setup"
  #before "deploy", "ruby:setup"
  #after "deploy", "github:setup"
  after 'deploy', 'bundle:install'
  desc 'start appliction'
  task :start do
    on roles(:web) do
      execute "$ruby #{release_path}/server.rb"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:web) do
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

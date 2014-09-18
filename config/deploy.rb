# config valid only for Capistrano 3.1
lock '3.2.1'
require 'json'

load "config/recipes/env_setup.rb"
load "config/recipes/ruby_setup.rb"
load "config/recipes/bundle_install.rb"
load "config/recipes/nginx_setup.rb"
load "config/recipes/swift_setup.rb"
load "config/recipes/nginx_swift_setup.rb"
load "config/recipes/postgresql_setup.rb"
load "config/recipes/github_setup.rb"

set :user, "devops"
set :application, 'newhire'
set :repo_url, 'git@github.com:/teddy-hoo/newhire-1'
set :scm, :git
set :pty, false

namespace :deploy do
 
  before "swift:setup","nginx_swift:setup" 
  before "ruby:setup", "swift:setup"
  before "postgresql:setup", "ruby:setup"
  before "nginx:setup", "postgresql:setup"
  before "deploy", "nginx:setup"

  task :dbsetup do
    on roles(:db) do
	  dbuser         = DbInfo['username']
      postgresql_pwd = DbInfo['password'].gsub('$','\$')
      dbname         = DbInfo['dbname']

      within release_path do
        execute :rake, 'config:create'
      end
      if "#{deploy_to}".include? "staging"
        within release_path do
          host = Servers["servers"]["staging"]["db"][0]['ip']
          execute "echo 'export RACK_ENV=staging' | cat - ~/.bashrc > tmp"
          execute "mv -f ~/tmp ~/.bashrc"
          execute "rm -f ~/tmp"
          execute ". ~/.bashrc"

          execute "cd #{release_path} && sed -i '7s/.*/  host: ldap.vmware.com/' config/config.yml"
          execute "cd #{release_path} && sed -i '8s/.*/  port: 389/' config/config.yml"
          execute "cd #{release_path} && sed -i '9s/.*/  base: dc=vmware,dc=com/' config/config.yml"

          execute "cd #{release_path} && sed -i '17s/.*/  username: #{dbuser}/' config/database.yml"
          execute "cd #{release_path} && sed -i '18s/.*/  password: #{postgresql_pwd}/' config/database.yml"
          execute "cd #{release_path} && sed -i '19s/.*/  host: #{host}/' config/database.yml"
 
          execute "cd #{release_path} && nohup rackup -D"

        end
      end
      within release_path do
        execute :rake, 'db:migrate'
        execute :rake, 'db:seed'
      end

	end
    on roles(:sinatra) do
      dbuser         = DbInfo['username']
      postgresql_pwd = DbInfo['password'].gsub('$','\$')
      dbname         = DbInfo['dbname']

      within release_path do
        execute :rake, 'config:create'
      end
      if "#{deploy_to}".include? "staging"
        within release_path do
          host = Servers["servers"]["staging"]["db"][0]['ip']
          execute "echo 'export RACK_ENV=staging' | cat - ~/.bashrc > tmp"
          execute "mv -f ~/tmp ~/.bashrc"
          execute "rm -f ~/tmp"
          execute ". ~/.bashrc"

          execute "cd #{release_path} && sed -i '7s/.*/  host: ldap.vmware.com/' config/config.yml"
          execute "cd #{release_path} && sed -i '8s/.*/  port: 389/' config/config.yml"
          execute "cd #{release_path} && sed -i '9s/.*/  base: dc=vmware,dc=com/' config/config.yml"

          execute "cd #{release_path} && sed -i '17s/.*/  username: #{dbuser}/' config/database.yml"
          execute "cd #{release_path} && sed -i '18s/.*/  password: #{postgresql_pwd}/' config/database.yml"
          execute "cd #{release_path} && sed -i '19s/.*/  host: #{host}/' config/database.yml"

        end
      elsif "#{deploy_to}".include? "production"
        host = Servers["servers"]["production"]["db"][0]['ip']
        execute "echo 'export RACK_ENV=production' | cat - ~/.bashrc > tmp"
        execute "mv -f ~/tmp ~/.bashrc"
        execute "rm -f ~/tmp"
        execute ". ~/.bashrc"

        execute "cd #{release_path} && sed -i '7s/.*/  host: ldap.vmware.com/' config/config.yml"
        execute "cd #{release_path} && sed -i '8s/.*/  port: 389/' config/config.yml"
        execute "cd #{release_path} && sed -i '9s/.*/  base: dc=vmware,dc=com/' config/config.yml"

        execute "cd #{release_path} && sed -i '25s/.*/  username: #{dbuser}/' config/database.yml"
        execute "cd #{release_path} && sed -i '26s/.*/  password: #{postgresql_pwd}/' config/database.yml"
        execute "cd #{release_path} && sed -i '27s/.*/  host: #{host}/' config/database.yml"
      end
    end
  end

  before :dbsetup, "bundle:install"
  before :restart, :dbsetup

  desc 'Restart application'
  task :restart do
    on roles(:sinatra), in: :sequence, wait: 5 do
      if "#{deploy_to}".include? "production"
        execute "ps aux | grep -i rackup | awk {'print $2'} | xargs kill -9"
      end
      execute "cd #{release_path} && nohup rackup -D"
      execute "echo 'done'"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :rake, 'cache:clear'
      end
    end
  end

end

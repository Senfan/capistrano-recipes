# config valid only for Capistrano 3.1
lock '3.2.1'
require 'json'

load "config/recipes/env_setup.rb"
load "config/recipes/ruby_setup.rb"
load "config/recipes/bundle_install.rb"
load "config/recipes/nginx_setup.rb"
load "config/recipes/postgresql_setup.rb"
load "config/recipes/github_setup.rb"

set :user, "devops"
set :application, 'newhire'
set :repo_url, 'git@github.com:/teddy-hoo/newhire-1'
set :scm, :git
set :pty, false

namespace :deploy do

  before "postgresql:setup", "ruby:setup"
  before "nginx:setup", "postgresql:setup"
  before "deploy", "nginx:setup"

  task :dbsetup do
    on roles(:sinatra) do
      if "#{deploy_to}".include? "staging"
        within release_path do
          execute :rake, 'config:create'
          execute :rake, 'db:migrate'
          execute :rake, 'db:seed'
          execute "cd #{release_path} && sed -i '7s/.*/  host: ldap.vmware.com/' config/config.yml"
          execute "cd #{release_path} && sed -i '8s/.*/  port: 389/' config/config.yml"
          execute "cd #{release_path} && sed -i '9s/.*/  base: dc=vmware,dc=com/' config/config.yml"
        end
      elsif "#{deploy_to}".include? "production"
        execute "cd #{deploy_to} && cp config.tar.gz #{release_path}"
        execute "cd #{release_path} && rm -r config/"
        execute "cd #{release_path} && tar -zxvf config.tar.gz"
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
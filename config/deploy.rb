# config valid only for Capistrano 3.1
lock '3.2.1'
require 'json'

load "config/env_setup.rb"
load "config/ruby_setup.rb"
load "config/bundle_install.rb"
load "config/nginx_setup.rb"
load "config/postgresql_setup.rb"
load "config/github_setup.rb"

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
      within release_path do
        execute :rake, 'config:create'
        execute :rake, 'db:migrate'
        execute :rake, 'db:seed'
        execute "cd #{release_path} && sed -i '7s/.*/  host: ldap.vmware.com/' config/config.yml"
        execute "cd #{release_path} && sed -i '8s/.*/  port: 389/' config/config.yml"
        execute "cd #{release_path} && sed -i '9s/.*/  base: dc=vmware,dc=com/' config/config.yml"
      end
    end
  end

  before :dbsetup, "bundle:install"
  before :restart, :dbsetup

  desc 'Restart application'
  task :restart do
    on roles(:sinatra), in: :sequence, wait: 5 do
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

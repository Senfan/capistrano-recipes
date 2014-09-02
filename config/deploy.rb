# config valid only for Capistrano 3.1
lock '3.2.1'
require 'json'

load "config/env_setup.rb"
load "config/ruby_setup.rb"
load "config/bundle_install.rb"
load "config/nginx_setup.rb"
load "config/postgresql_setup.rb"

set :user, "devops"
set :application, 'newhire'
set :repo_url, 'git@github.com:/vmwarechina/newhire'
set :scm, :git

namespace :staging do
  desc "for staging env deploy"

  before "ruby:setup", "env:setup"
  before "postgresql:setup", "ruby:setup"
  before "nginx:setup", "postgresql:setup"
  before "deploy", "nginx:setup"
  task :deploy do
    # config db
    # start sinatra 
    on roles(:sinatra) do
      execute "cd #{deploy_to} && rackup"
    end
  end
end

namespace :testing do
  desc "for production env deploy"

  before "ruby:update", "env:update"
  before "postgresql:update", "ruby:update"
  before "nginx:update", "postgresql:update"
  before "deploy", "nginx:update"
  task :deploy do
    # config db
    # start sinatra 
    on roles(:sinatra) do
      execute "cd #{deploy_to} && rackup"
    end
  end
end

namespace :production do
  desc "for production env deploy"

  before "ruby:update", "env:update"
  before "postgresql:update", "ruby:update"
  before "nginx:update", "postgresql:update"
  before "deploy", "nginx:update"
  task :deploy do
    # config db
    # start sinatra 
    on roles(:sinatra) do
      execute "cd #{deploy_to} && rackup"
    end
  end
end

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
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

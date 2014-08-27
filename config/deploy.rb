# config valid only for Capistrano 3.1
lock '3.2.1'


ruby_version="2.1.2"

set :application, 'newhire'
set :user, "devops"
set :scm, :git
set :repo_url, "git@github.com/vmwarechina/newhire"
set :deploy_to, "/home/#{user}/webapp"
set :pty, true

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

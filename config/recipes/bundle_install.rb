#for role:
# => :sinatra

namespace :bundle do
  desc 'run bundle install'
  task :install do
    on roles(:sinatra) do
      execute "cd #{release_path} && bundle install"
    end
  end
end
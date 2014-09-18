#for role:
# => :sinatra

namespace :bundle do
  desc 'run bundle install'
  task :install do
    if "#{deploy_to}".include? "staging" or "#{deploy_to}".include? "production"
      on roles(:sinatra) do
        execute "cd #{release_path} && bundle install"
      end
	else 
	  on roles(:all_in_one) do
        execute "cd #{release_path} && bundle install"
      end
	end
  end
end
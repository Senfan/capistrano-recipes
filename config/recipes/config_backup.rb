namespace :config do

  desc "backup sinatra config file"
  task :backup do
    on roles(:sinatra) do
      if "#{deploy_to}".include? "production"
        execute "cd #{deploy_to} && tar -zcvf config.tar.gz ./config/"
        execute "cd #{deploy_to} && mv -f config.tar.gz ../"
      end
    end
  end

end

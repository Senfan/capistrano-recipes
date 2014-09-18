namespace :github do

  desc "configure github environment"
  task :setup do
    if "#{deploy_to}".include? "testing"
	  on roles(all_in_one) do
		execute "printf 'Host github.com \\n\\t User git" +
              " \\n\\t Hostname ssh.github.com" +
              " \\n\\t PreferredAuthentications publickey" +
              " \\n\\t IdentityFile ~/.ssh/id_rsa" +
              " \\n\\t Port 443\\n' > ~/.ssh/config"
        execute "eval $(ssh-agent)"
        execute "ssh-add"
      end
	else
      on roles(:sinatra, :nginx, :db) do
        execute "printf 'Host github.com \\n\\t User git" +
              " \\n\\t Hostname ssh.github.com" +
              " \\n\\t PreferredAuthentications publickey" +
              " \\n\\t IdentityFile ~/.ssh/id_rsa" +
              " \\n\\t Port 443\\n' > ~/.ssh/config"
        execute "eval $(ssh-agent)"
        execute "ssh-add"
      end
	end
  end
 
end

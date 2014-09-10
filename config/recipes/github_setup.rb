namespace :github do

  desc "configure github environment"
  task :setup do
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

namespace :github do

  desc "configure github environment"
  task :setup do
    on roles(:web) do
      ask(:email, "input email address: ")
      execute "printf 'Host github.com \\n\\t User git" +
              " \\n\\t Hostname ssh.github.com" +
              " \\n\\t PreferredAuthentications publickey" +
              " \\n\\t IdentityFile ~/.ssh/id_rsa" +
              " \\n\\t Port 443\\n' > ~/.ssh/config"
      file = "~/.ssh/id_rsa"
      public_file = "#{file}.pub"
      execute "git config --global user.email '#{fetch(:email)}'"
      if capture("if [ -f #{file} ]; then echo 'true'; fi") == ''
        execute "ssh-keygen -q -t rsa -C '#{fetch(:email)}' -N '' -f '~/ssh/id_rsa' "
      end
      key = capture("cat #{public_file}")
      ask(:username, "input github username: ")
      ask(:password, "input github password: ")
      github = Github.new( login: "#{fetch(:username)}", password: "#{fetch(:password)}" )
      github.users.keys.create( title: "capistrano generated", key: key )
    end
  end
 
end
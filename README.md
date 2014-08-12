capistrano-recipes
==================

Common recipes

#deploy steps
1. install openssh-server to your ubuntu server
2. generate isa keys: ssh-keygen -q -t rsa -C '#{yourEmailAddress}' -N '' -f '~/.ssh/id_rsa'
3. copy your Authorized rsa keys to server
4. add the below two lines to /etc/sudoers file using command "sudo visudo"
   "user_name ALL=NOPASSWD: /usr/bin/apt-get -y install *"
   "user_name ALL=NOPASSWD: /usr/bin/apt-get -y update"
5. change the user name and host address in config/server.json file
6. use command "cap deploy" to deploy your project

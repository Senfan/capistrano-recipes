capistrano-recipes
==================

Common recipes

#deploy steps
1. install openssh-server to your ubuntu server
2. copy your Authorized rsa keys to server
3. add the below two lines to /etc/sudoers file using command "sudo visudo"
   "user_name ALL=NOPASSWD: /usr/bin/apt-get -y install *"
   "user_name ALL=NOPASSWD: /usr/bin/apt-get -y update"
4. change the user name and host address in deploy.rb
5. use command "cap deploy" to deploy your project

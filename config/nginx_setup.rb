#for role:
# => nginx

require_relative 'loadinfo'

namespace :nginx do
   desc "install nginx"
   task :setup do
      on roles(:nginx) do
         if "#{deploy_to}".include? "production"
             root_path = "production"
             sinatraweb1 = Servers['servers']['production']['sinatra'][0]['ip']
             sinatraweb2 = Servers['servers']['production']['sinatra'][1]['ip']
             execute "sudo /etc/init.d/nginx stop"
         elsif "#{deploy_to}".include? "staging"
             root_path = "staging"
             sinatraweb1 = Servers['servers']['staging']['sinatra'][0]['ip']
             sinatraweb2 = Servers['servers']['staging']['sinatra'][1]['ip']
             execute "sudo apt-get -y install nginx"
             execute "sudo /etc/init.d/nginx stop"
         else
             root_path = "webapp"
             execute "sudo apt-get -y install nginx"
             execute "sudo /etc/init.d/nginx stop"
         end
         
         execute "sudo bash -c \"echo -e 'user www-data; \\n " +
                 "worker_processes 4; \\n pid /run/nginx.pid;\\n " +
                 "events {\\n worker_connections 768;\\n  }\\n " +
                 "http {\\n upstream webservers {\\n  server #{sinatraweb1}:9292 ;\\n " +
                 "server #{sinatraweb2}:9292 ;\\n }\\n server {\\n listen       80; \\n" +
                 "location =/ { \\n root  /home/devops/#{root_path}/current/; \\n index   index.html; \\n } \\n" +
                 "location ~ .*\\.(gif|jpg|jpeg|png|bmp|swf|js|html|htm|css)\$ { \\n" +
                 "root  /home/devops/#{root_path}/current/; \\n }\\n" +
                 "server_name  webservers;\\n location / {\\n " +
                 "proxy_pass  http://webservers/;\\n " +
                 "}\\n }\\n sendfile on;\\n tcp_nopush on;\\n tcp_nodelay on;\\n" +
                 "keepalive_timeout 65;\\n types_hash_max_size 2048;\\n " +
                 "include /etc/nginx/mime.types;\\n default_type application/octet-stream;\\n " +
                 "access_log /var/log/nginx/access.log;\\n  " +
                 "error_log /var/log/nginx/error.log;\\n  " +
                 "gzip on;\\n   gzip_disable 'msie6';\\n " +
                 "}\\n '  > /etc/nginx/nginx.conf \"  "
         execute "sudo /etc/init.d/nginx start"
     end
   end
end

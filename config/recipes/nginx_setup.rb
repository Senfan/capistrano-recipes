#for role:
# => nginx
namespace :nginx do
    desc "install nginx"
    task :setup do
        root_path = ""
        if "#{deploy_to}".include? "testing"
          on roles(:all_in_one) do
            if "#{deploy_to}".include? "testing0"
                root_path = "testing0"
                sinatraweb1 = Servers['servers']['testing0']['sinatra'][0]['ip']
                puts "#{sinatraweb1}"
                execute "sudo apt-get -y install nginx"
                execute "sudo /etc/init.d/nginx stop"
            elsif "#{deploy_to}".include? "testing1"
                root_path = "testing1"
                sinatraweb1 = Servers['servers']['testing1']['sinatra'][0]['ip']
                puts "#{sinatraweb1}"
                execute "sudo apt-get -y install nginx"
                execute "sudo /etc/init.d/nginx stop"
            elsif "#{deploy_to}".include? "testing2"
                root_path = "testing2"
                sinatraweb1 = Servers['servers']['testing2']['sinatra'][0]['ip']
                puts "#{sinatraweb1}"
                execute "sudo apt-get -y install nginx"
                execute "sudo /etc/init.d/nginx stop"
            elsif "#{deploy_to}".include? "testing3"
                root_path = "testing3"
                puts "here"
                sinatraweb1 = Servers['servers']['testing3']['sinatra'][0]['ip']
                puts "#{sinatraweb1}"
                execute "sudo apt-get -y install nginx"
                execute "sudo /etc/init.d/nginx stop"
            elsif "#{deploy_to}".include? "testing4"
                root_path = "testing4"
                sinatraweb1 = Servers['servers']['testing4']['sinatra'][0]['ip']
                puts "#{sinatraweb1}"
                execute "sudo apt-get -y install nginx"
                execute "sudo /etc/init.d/nginx stop"
			else "#{deploy_to}".include? "testingVM"
                root_path = "testingVM"
                sinatraweb1 = Servers['servers']['testingVM']['sinatra'][0]['ip']
                puts "#{sinatraweb1}"
                execute "sudo apt-get -y install nginx"
                puts root_path
                execute "sudo /etc/init.d/nginx stop"
            end
          end
        else
          on roles(:nginx) do
            if "#{deploy_to}".include? "production"
                root_path = "production"
                sinatraweb1 = Servers['servers']['production']['sinatra'][0]['ip']
                sinatraweb2 = Servers['servers']['production']['sinatra'][1]['ip']
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
          end
        end
		if "#{deploy_to}".include? "testing"
          on roles(:all_in_one) do
          execute "sudo bash -c \"echo -e 'user www-data; \\n" +
          "worker_processes 4; \\n" +
          "pid /run/nginx.pid;\\n" +
           "events {\\n" +
           "worker_connections 768;\\n" +
                "}\\n" +
                "http {\\n" +
                "upstream webservers {\\n" + "server 127.0.0.1:9292;\\n" +
                "}\\n" +
                #"upstream swiftservers{\\n" + swiftserverlist +
                #"}\\n" +
                "server {\\n" +
                "listen  80; \\n" +
                "location =/ { \\n" +
                "root  /home/devops/#{root_path}/current/; \\n" +
                "index   index.html; \\n" +
                "} \\n" +
                "location ~ .*\\.(gif|jpg|jpeg|png|bmp|swf|js|html|htm|css)\$ { \\n" +
                "root  /home/devops/#{root_path}/current/; \\n" +
                "}\\n" +
                "server_name  webservers;\\n" +
                "location / {\\n" +
                "proxy_pass  http://webservers/;\\n" +
                "}\\n" +
                #"location /auth {\\n" +
                #"proxy_pass http://swiftservers/;\\n"+
                #"}\\n" +
                "}\\n" +
                "sendfile on;\\n" +
                "tcp_nopush on;\\n" +
                "tcp_nodelay on;\\n" +
                "keepalive_timeout 65;\\n" +
                "types_hash_max_size 2048;\\n" +
                "include /etc/nginx/mime.types;\\n" +
                "default_type application/octet-stream;\\n" +
                "access_log /var/log/nginx/access.log;\\n" +
                "error_log /var/log/nginx/error.log;\\n" +
                "gzip on;\\n" +
                "gzip_disable 'msie6';\\n" +
                "}\\n'  > /etc/nginx/nginx.conf \"  "
               end
             else
			  on roles(:nginx) do
                 execute "sudo bash -c \"echo -e 'user www-data; \\n" +
                            "worker_processes 4; \\n" +
                                "pid /run/nginx.pid;\\n" +
                                "events {\\n" +
                                "worker_connections 768;\\n" +
                                "}\\n" +
                                "http {\\n" +
                                "upstream webservers {\\n" + sinatraweblist +
                                "}\\n" +
                                #"upstream swiftservers{\\n" + swiftserverlist +
                                #"}\\n" +
                                "server {\\n" +
                                "listen  80; \\n" +
                                "location =/ { \\n" +
                                "root  /home/devops/#{root_path}/current/; \\n" +
                                "index   index.html; \\n" +
                                "} \\n" +
                                "location ~ .*\\.(gif|jpg|jpeg|png|bmp|swf|js|html|htm|css)\$ { \\n" +
                                "root  /home/devops/#{root_path}/current/; \\n" +
                                "}\\n" +
                                "server_name  webservers;\\n" +
                                "location / {\\n" +
                                "proxy_pass  http://webservers/;\\n" +
                                "}\\n" +
                                #"location /auth {\\n" +
                                #"proxy_pass http://swiftservers/;\\n"+
                                #"}\\n" +
                                "}\\n" +
                                "sendfile on;\\n" +
                                "tcp_nopush on;\\n" +
                                "tcp_nodelay on;\\n" +
                                "keepalive_timeout 65;\\n" +
                                "types_hash_max_size 2048;\\n" +
                                "include /etc/nginx/mime.types;\\n" +
                                "default_type application/octet-stream;\\n" +
                                "access_log /var/log/nginx/access.log;\\n" +
                                "error_log /var/log/nginx/error.log;\\n" +
                                "gzip on;\\n" +
                                "gzip_disable 'msie6';\\n" +
                                "}\\n'  > /etc/nginx/nginx.conf \"  "
            end
          end
		  
		   if "#{deploy_to}".include? "production"
            on roles(:nginx) do
              execute "sudo service nginx reload"
            end
         elsif "#{deploy_to}".include? "staging"
            on roles(:nginx) do
              execute "sudo /etc/init.d/nginx start"
            end
         else
            on roles(:all_in_one) do
              execute "sudo /etc/init.d/nginx start"
            end
         end
       end
    end
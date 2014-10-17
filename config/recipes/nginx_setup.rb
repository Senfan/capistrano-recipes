#for role:
# => nginx
namespace :nginx do
    desc "install nginx"
    task :setup do
        on roles(:nginx) do
            sinatraweblist = ""
            swiftserverlist = ""
            proxyport     = SwiftInfo['proxyport']
            swift_nginx   = ""
            if "#{deploy_to}".include? "production"
                root_path    = "production"
                sinatrawebp  = Servers['servers']['production']['sinatra']
                swift_hosts  = Servers["servers"]["production"]["swift"]
                swift_nginx  =Servers["servers"]["production"]["swift-nginx"][0]["ip"]

            elsif "#{deploy_to}".include? "staging"
                root_path = "staging"
                sinatrawebp  = Servers['servers']['staging']['sinatra']
                swift_hosts  = Servers["servers"]["staging"]["swift"]
                swift_nginx  = Servers["servers"]["staging"]["swift-nginx"][0]["ip"]
            elsif "#{deploy_to}".include? "fresh"
                root_path = "fresh"
                sinatrawebp  = Servers['servers']['fresh']['sinatra']
                swift_hosts  = Servers["servers"]["fresh"]["swift"]
                swift_nginx  = Servers["servers"]["fresh"]["swift-nginx"][0]["ip"]
                execute "sudo apt-get -y install nginx"
                execute "sudo /etc/init.d/nginx stop"
            else
                root_path = "webapp"
                execute "sudo apt-get -y install nginx"
                execute "sudo /etc/init.d/nginx stop"
            end

            sinatrawebp.each { |host|
                sinatraweblist = sinatraweblist+ "server " + "#{host["ip"]}" +":9292;\\n"
            }
            #swift_hosts.each { |host|
            #   swiftserverlist = swiftserverlist +"server "+ "#{host["ip"]}" +":#{proxyport};\\n"
            #}

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
            "location /auth/v1.0 {\\n" +
            "proxy_pass  http://\"#{swift_nginx}\";\\n" +
            "}\\n" +
            "location /v1 {\\n" +
            "proxy_pass  http://\"#{swift_nginx}\";\\n" +
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

            if "#{deploy_to}".include? "production" or "#{deploy_to}".include? "staging"
                execute "sudo service nginx reload"
            else
                execute "sudo /etc/init.d/nginx start"
            end
        end
    end
end

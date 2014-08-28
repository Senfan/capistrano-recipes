#for role web
#
namespace :nginx do
   desc "install nginx"
   task :setup do
      on roles(:web) do
         execute "sudo apt-get -y install nginx"
         execute "sudo bash -c \"echo -e 'user www-data; \\n  worker_processes 4; \\n pid /run/nginx.pid;\\n events {\\n worker_connections 768;\\n  }\\n http {\\n upstream webservers {\\n  server #{sinatraweb1} ;\\n server #{sinatraweb2} ;\\n }\\n server {\\n listen       80; \\n server_name  webservers;\\n location / {\\n proxy_pass      http://webservers;\\n proxy_redirect off;\\n }\\n }\\n sendfile on;\\n tcp_nopush on;\\n tcp_nodelay on;\\n keepalive_timeout 65;\\n types_hash_max_size 2048;\\n include /etc/nginx/mime.types;\\n default_type application/octet-stream;\\n  access_log /var/log/nginx/access.log;\\n   error_log /var/log/nginx/error.log;\\n   gzip on;\\n   gzip_disable 'msie6';\\n   }\\n '  > /etc/nginx/nginx.conf \"  "
         execute "sudo /etc/init.d/nginx restart"
     end
   end
end

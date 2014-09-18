require_relative "../loadinfo/loadinfo_testing3"

user          = 'devops'
#server "#{Docker_host}:#{Container_port}", user: "devops", roles: %w{sinatra nginx db} 
set :deploy_to, "/home/#{user}/testing3"
nginx_hosts   = Servers["servers"]["testing3"]["nginx"]
sinatra_hosts = Servers["servers"]["testing3"]["sinatra"]
db_hosts      = Servers["servers"]["testing3"]["db"]

nginx_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{nginx}
}

sinatra_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{sinatra}
}

db_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{db}
}
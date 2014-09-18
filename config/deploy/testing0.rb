require_relative "../loadinfo/loadinfo_testing0"

user          = 'devops'
#server "#{Docker_host}:#{Container_port}", user: "devops", roles: %w{sinatra nginx db} 
set :deploy_to, "/home/#{user}/testing0"
nginx_hosts   = Servers["servers"]["testing0"]["nginx"]
sinatra_hosts = Servers["servers"]["testing0"]["sinatra"]
db_hosts      = Servers["servers"]["testing0"]["db"]

nginx_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{nginx}
}

sinatra_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{sinatra}
}

db_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{db}
}
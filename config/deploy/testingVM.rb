require_relative "../loadinfo/loadinfo_testingVM"

user          = 'devops'
#server "#{Docker_host}:#{Container_port}", user: "devops", roles: %w{sinatra nginx db} 
set :deploy_to, "/home/#{user}/testing"
nginx_hosts   = Servers["servers"]["testingVM"]["nginx"]
sinatra_hosts = Servers["servers"]["testingVM"]["sinatra"]
db_hosts      = Servers["servers"]["testingVM"]["db"]

nginx_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{nginx}
}

sinatra_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{sinatra}
}

db_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{db}
}

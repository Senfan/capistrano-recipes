require_relative "../loadinfo/loadinfo_testing2"

user          = 'devops'
set :deploy_to, "/home/#{user}/testing1"

nginx_hosts   = Servers["servers"]["testing2"]["nginx"]
sinatra_hosts = Servers["servers"]["testing2"]["sinatra"]
db_hosts      = Servers["servers"]["testing2"]["db"]

nginx_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

sinatra_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

db_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

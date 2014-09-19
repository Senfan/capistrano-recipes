require_relative "../loadinfo/loadinfo_testing0"

user          = 'devops'
#server "#{Docker_host}:#{Container_port}", user: "devops", roles: %w{sinatra nginx db} 
set :deploy_to, "/home/#{user}/testing0"
set :repo_url, 'git@github.com:/teddy-hoo/newhire-1'
nginx_hosts   = Servers["servers"]["testing0"]["nginx"]
sinatra_hosts = Servers["servers"]["testing0"]["sinatra"]
db_hosts      = Servers["servers"]["testing0"]["db"]

nginx_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

sinatra_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

db_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}
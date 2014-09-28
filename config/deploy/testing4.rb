require_relative "../loadinfo/loadinfo_testing4"

set :deploy_to, "/home/#{user}/testing4"
set :repo_url, 'git@github.com:/teddy-hoo/newhire-1'

user          = 'devops'
nginx_hosts   = Servers["servers"]["testing4"]["nginx"]
sinatra_hosts = Servers["servers"]["testing4"]["sinatra"]
db_hosts      = Servers["servers"]["testing4"]["db"]

nginx_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

sinatra_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

db_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

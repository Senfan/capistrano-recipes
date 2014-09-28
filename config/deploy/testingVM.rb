require_relative "../loadinfo/loadinfo_testingVM"

set :deploy_to, "/home/#{user}/testingVM"
set :repo_url, 'git@github.com:/teddy-hoo/newhire-1'

user          = 'devops'
nginx_hosts   = Servers["servers"]["testingVM"]["nginx"]
sinatra_hosts = Servers["servers"]["testingVM"]["sinatra"]
db_hosts      = Servers["servers"]["testingVM"]["db"]

nginx_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

sinatra_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

db_hosts.each { |host|
        server "#{host['ip']}", user: "#{user}", roles: %w{all_in_one}
}

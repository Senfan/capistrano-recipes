require_relative '../loadinfo/loadinfo_production'

user          = 'devops'
nginx_hosts   = Servers["servers"]["production"]["nginx"]
sinatra_hosts = Servers["servers"]["production"]["sinatra"]
db_hosts      = Servers["servers"]["production"]["db"]
set :deploy_to, "/home/#{user}/production"

nginx_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{nginx}
}

sinatra_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{sinatra}
}

db_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{db}
}

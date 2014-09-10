require_relative '../loadinfo'

user          = 'devops'
nginx_hosts   = Servers["servers"]["staging"]["nginx"]
sinatra_hosts = Servers["servers"]["staging"]["sinatra"]
db_hosts      = Servers["servers"]["staging"]["db"]
set :deploy_to, "/home/#{user}/staging"

nginx_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{nginx}
}

sinatra_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{sinatra}
}

db_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{db}
}

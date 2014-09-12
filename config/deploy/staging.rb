require_relative '../loadinfo/loadinfo_staging'

user          = 'devops'
nginx_hosts   = Servers["servers"]["staging"]["nginx"]
sinatra_hosts = Servers["servers"]["staging"]["sinatra"]
db_hosts      = Servers["servers"]["staging"]["db"]
swift_hosts   = Servers["servers"]["staging"]["swift"]

set :deploy_to, "/home/#{user}/staging"
swift_hosts.each { |host| 
   server "#{host['ip']}", user: "#{user}", roles: %w{storage}
}
nginx_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{nginx}
}

sinatra_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{sinatra}
}

db_hosts.each { |host| 
	server "#{host['ip']}", user: "#{user}", roles: %w{db}
}

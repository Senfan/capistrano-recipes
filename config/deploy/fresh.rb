require_relative '../loadinfo/loadinfo_fresh'


user                = 'devops'
nginx_hosts         = Servers["servers"]["fresh"]["nginx"]
sinatra_hosts       = Servers["servers"]["fresh"]["sinatra"]
db_hosts            = Servers["servers"]["fresh"]["db"]
swift_hosts         = Servers["servers"]["fresh"]["swift"]
swift_nginx_hosts   = Servers["servers"]["fresh"]["swift-nginx"]

set :deploy_to, "/home/#{user}/fresh"

swift_hosts.each { |host| 
   server "#{host['ip']}", user: "#{user}", roles: %w{storage}, no_release: true
}

swift_nginx_hosts.each { |host| 
   server "#{host['ip']}", user: "#{user}", roles: %w{nginx_swift}, no_release: true
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

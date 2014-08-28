require-relative '../loadinfo'

user          = 'devops'
nginx_hosts   = Servers["servers"]["staging"]["nginx"]
sinatra_hosts = Servers["servers"]["staging"]["sinatra"]
db_hosts      = Servers["servers"]["staging"]["db"]

nginx_hosts.each { |host| 
	server '#{host["ip"]}', user: "#{user}", roles: %w{nginx}
}

sinatra_hosts.each { |host| 
	server '#{host["ip"]}', user: "#{user}", roles: %w{sinatra}
}

db_hosts.each { |host| 
	server '#{host["ip"]}', user: "#{user}", roles: %w{db}
}

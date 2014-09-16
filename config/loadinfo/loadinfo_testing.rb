require 'json'
puts "starting"
Docker_host    = "10.110.178.112"
`ssh -t newhire@#{Docker_host} "sudo docker ps -a | grep 'test_container' && sudo docker rm -f test_container; sudo docker run -d -p 49190:22 -p 49080:80 --name test_container test_image_from_dockerfile"`

puts "step 2"
Container_port = `ssh -t newhire@#{Docker_host} "sudo docker port test_container 22 | cut -d ':' -f 2"`
#Container_ip = `ssh -t newhire@#{Docker_host} "sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' test_container"`
#puts Container_ip
puts "step 4"
server_info = File.read('./config/config_file/server.json')
Servers     = JSON.parse(server_info)
#Servers['servers']['testing']['sinatra'][0]['ip'] = Container_ip 
#Servers['servers']['testing']['nginx'][0]['ip']   = Container_ip
#Servers['servers']['testing']['db'][0]['ip']      = Container_ip

#File.open('./config/config_file/server.json', 'w') do |f|
#     f.write(Servers.to_json)
#end

db_info = File.read('./config/config_file/pg.json')
DbInfo  = JSON.parse(db_info)
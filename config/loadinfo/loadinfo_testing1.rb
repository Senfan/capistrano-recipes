require 'json'

Docker_host    = "10.110.178.112"
SSH_port       = "49122"
WEB_port       = "49180"
Container_name = "test_container1"
Docker_image   = "test_image_from_dockerfile"

server_info = File.read('./config/config_file/server.json')
Servers     = JSON.parse(server_info)
Servers["servers"]["testing1"]["nginx"][0]["ip"]   = Docker_host + ":" + SSH_port
Servers["servers"]["testing1"]["sinatra"][0]["ip"] = Docker_host + ":" + SSH_port
Servers["servers"]["testing1"]["db"][0]["ip"]      = Docker_host + ":" + SSH_port

File.open('./config/config_file/server.json', 'w') do |f|
        f.write(Servers.to_json)
end

db_info = File.read('./config/config_file/pg.json')
DbInfo  = JSON.parse(db_info)

`ssh -t newhire@#{Docker_host} "sudo docker ps -a | grep #{Container_name} && sudo docker rm -f #{Container_name}; sudo docker run -d -p #{SSH_port}:22 -p #{WEB_port}:80 --name #{Container_name} #{Docker_image}"`
`ssh -t newhire@#{Docker_host} "sudo docker inspect --format '{{ .NetworkSettings.IPAddress }}' test_container"`
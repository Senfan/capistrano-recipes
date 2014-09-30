require 'json'

set :repo_url, 'git@github.com:/teddy-hoo/newhire-1'
Docker_host    = "10.110.178.112"
Swift_host     = "10.110.178.38:8080"
SSH_port       = "49222"
WEB_port       = "49280"
Container_name = "test_container2"
Docker_image   = "test_image_from_dockerfile"
SSHKey_path_DH = "/home/newhire/dockerfile/gitKeys/"
Key_name       = "id_rsa"

server_info = File.read('./config/config_file/server.json')
Servers     = JSON.parse(server_info)
Servers["servers"]["testing2"]["nginx"][0]["ip"]   = Docker_host + ":" + SSH_port
Servers["servers"]["testing2"]["sinatra"][0]["ip"] = Docker_host + ":" + SSH_port
Servers["servers"]["testing2"]["db"][0]["ip"]      = Docker_host + ":" + SSH_port
Servers["servers"]["testing2"]["swift"][0]["ip"]   = Swift_host

File.open('./config/config_file/server.json', 'w') do |f|
        f.write(Servers.to_json)
end

db_info = File.read('./config/config_file/pg.json')
DbInfo  = JSON.parse(db_info)

`ssh -t newhire@#{Docker_host} "sudo docker ps -a | grep #{Container_name} && sudo docker rm -f #{Container_name}; sudo docker run -d -p #{SSH_port}:22 -p #{WEB_port}:80 --name #{Container_name} #{Docker_image}"`

`ssh -t newhire@#{Docker_host} "scp -P #{SSH_port} #{SSHKey_path_DH}#{Key_name} devops@#{Docker_host}:/home/devops/.ssh/#{Key_name}"`

`ssh -t devops@#{Docker_host} -p #{SSH_port} "printf 'Host github.com\\n\\t User git\\n\\t \"Hostname\" ssh.github.com\\n\\t PreferredAuthentications publickey\\n\\t IdentityFile ~/.ssh/#{Key_name}\\n\\t Port 443\\n' > /home/devops/.ssh/config"`

`ssh -t newhire@#{Docker_host} "sudo docker port test_container 22 | cut -d ':' -f 2"`

require 'json'

Docker_host = "10.110.178.112"

`ssh -t newhire@#{Docker_host} "sudo docker ps -a | grep 'test_container' && sudo docker rm -f test_container; sudo docker run -d -P --name test_container test_image_from_dockerfile"`

Container_port=`ssh -t newhire@#{Docker_host} "sudo docker port test_container 22 | cut -d ':' -f 2"`

db_info = File.read('./config/config_file/pg.json')
DbInfo  = JSON.parse(db_info)

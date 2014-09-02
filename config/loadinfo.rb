require 'json'
require_relative './vm_access'
#read server list from server.json
#json structure refer to server.json
server_info = File.read('./config/server.json')
Servers     = JSON.parse(server_info)

#weiqi provide the following two method
vma = VmAccess.new('10.110.178.12','root','vmware','Datacenter','ubuntu14.04_template')
vma.remove_vms(Servers) # remove existing vms
vma.create_vms(Servers) # create new vms and write info to servers object

#write new server info to file
File.open('./config/server.json', 'w') do |f|
	f.write(Servers.to_json)
end

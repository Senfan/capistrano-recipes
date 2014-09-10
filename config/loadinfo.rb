require 'json'
require_relative './vm_access'

server_info = File.read('./config/server.json')
Servers     = JSON.parse(server_info)

vma = VmAccess.new('10.110.178.12','root','vmware','Datacenter','cluster','ubuntu14.04_template')

vma.remove_vms(Servers)
vma.create_vms(Servers)

File.open('./config/server.json', 'w') do |f|
	f.write(Servers.to_json)
end

db_info = File.read('./config/pg.json')
DbInfo  = JSON.parse(db_info)

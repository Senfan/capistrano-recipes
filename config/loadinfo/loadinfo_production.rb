require 'json'
require_relative './vm_access'

server_info = File.read('./config/config_file/server.json')
Servers     = JSON.parse(server_info)

db_info = File.read('./config/config_file/pg.json')
DbInfo  = JSON.parse(db_info)

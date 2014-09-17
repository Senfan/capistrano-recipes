require_relative "../loadinfo/loadinfo_testing"

server "#{Docker_host}:#{Container_port}", user: "devops", roles: %w{sinatra}

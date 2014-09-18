#for role:
# => :nginx
# => :sinatra
# => :db  

namespace :env do
  desc "environment setup"
  task :setup do
    if "#{deploy_to}".include? "testing"
	  on roles(:all_in_one) do
        pkgs = %w(git gcc make libxslt-dev zlib1g-dev libxml2-dev libxml2 libxslt1.1 libxslt1-dev openssl libssl-dev g++ unzip sqlite3 libsqlite3-dev libpq-dev ntp libpcre3 libpcre3-dev)
        execute "sudo apt-get -y update"
        pkgs.each do |pkg|
          puts %{pkg}
          execute "sudo apt-get -y install #{pkg}"
        end
      end
	else
      on roles(:nginx, :sinatra, :db) do
        pkgs = %w(git gcc make libxslt-dev zlib1g-dev libxml2-dev libxml2 libxslt1.1 libxslt1-dev openssl libssl-dev g++ unzip sqlite3 libsqlite3-dev libpq-dev ntp libpcre3 libpcre3-dev)
        execute "sudo apt-get -y update"
        pkgs.each do |pkg|
          puts %{pkg}
          execute "sudo apt-get -y install #{pkg}"
        end
      end
    end
  end
end

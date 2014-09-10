#role for:
# => db
#
require_relative 'loadinfo'

dbuser          = DbInfo['username']
postgresql_pwd  = DbInfo['password'].gsub('$','\$')
webappdb        = DbInfo['dbname']
subnetwork      = DbInfo['subnetwork']


namespace :postgresql do
   desc "install postgresql"
   task :setup do
      on roles(:db) do
         if "#{deploy_to}".include? "staging"
             execute "sudo apt-get -y install postgresql"
             execute "sudo /etc/init.d/postgresql stop"
             execute "sudo  echo -e \"  data_directory = \'/var/lib/postgresql/9.3/main\'\\n" +
                     "hba_file = \'/etc/postgresql/9.3/main/pg_hba.conf\' \\n " +
                     "ident_file = \'/etc/postgresql/9.3/main/pg_ident.conf\' \\n " +
                     "external_pid_file = \'/var/run/postgresql/9.3-main.pid\' \\n " +
                     "listen_addresses = \'*\' \\n port = 5432 \\n " +
                     "max_connections = 100 \\n " +
                     "unix_socket_directories = \'/var/run/postgresql\' \\n " +
                     "ssl = true \\n " +
                     "ssl_cert_file = \'/etc/ssl/certs/ssl-cert-snakeoil.pem\'  \\n " +
                     "ssl_key_file = \'/etc/ssl/private/ssl-cert-snakeoil.key\' \\n " +
                     "shared_buffers = 128MB \\n log_line_prefix = \'%t \' \\n " +
                     "log_timezone = \'Hongkong\'  \\n datestyle = \'iso, mdy\' \\n " +
                     "timezone = \'Hongkong\'  \\n lc_messages = \'en_US.UTF-8\' \\n " +
                     "lc_monetary = \'en_US.UTF-8\' \\n  lc_numeric = \'en_US.UTF-8\' \\n " +
                     "lc_time = \'en_US.UTF-8\' \\n "+
                     "default_text_search_config = \'pg_catalog.english\' \\n \"   > ~/postgresql.conf  "
             execute "sudo bash -c  \" cat ~/postgresql.conf > /etc/postgresql/9.3/main/postgresql.conf \" "
             execute "sudo bash -c \" echo -e 'local   all postgres  peer \\n " +
                     "local   all             all                          peer   \\n " +
                     "host    all             all          127.0.0.1/32    trust  \\n " +
                     "host    all             all          #{subnetwork}   md5  \\n " + 
                     "host    all             all          ::1/128          md5' > /etc/postgresql/9.3/main/pg_hba.conf \" "
             execute "sudo /etc/init.d/postgresql restart"
             execute "sudo -u postgres createuser --superuser #{dbuser}"
             execute "sudo -u postgres createdb -O #{dbuser} #{webappdb}"
             execute "sudo -u postgres  psql -h 127.0.0.1 -p 5432 -c \"alter user #{dbuser}  password '#{postgresql_pwd}';\" "
             execute "sudo /etc/init.d/postgresql restart"
        end
      end
   end
end


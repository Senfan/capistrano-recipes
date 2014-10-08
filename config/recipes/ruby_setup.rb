#for role:
# => :sinatra

ruby_version = "2.1.2"

namespace :ruby do

  desc "install rbenv, ruby, and bundler"
  task :setup do
    if "#{deploy_to}".include? "testing"
       on roles(:all_in_one) do
         if capture("if [ -d ~/.rbenv ]; then echo 'true'; fi") == ''
           execute "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv"
         else
           execute "cd ~/.rbenv && git pull"
         end
         if capture("if grep rbenv ~/.bashrc; then echo 'true'; fi") == ''
           execute "echo 'eval \"$(rbenv init -)\"' | cat - ~/.bashrc > tmp"
           execute "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' | cat - tmp > tmp1"
           execute "mv -f ~/tmp1 ~/.bashrc"
           execute "rm -f ~/tmp"
           execute ". ~/.bashrc"
         end
         if capture("if [ -d ~/.rbenv/plugins/ruby-build ]; then echo 'true'; fi") == ''
           execute "git clone https://github.com/sstephenson/ruby-build ~/.rbenv/plugins/ruby-build"
           execute "rbenv rehash"
         else
           execute "cd ~/.rbenv/plugins/ruby-build && git pull"
           execute "rbenv rehash"
         end
         if capture("if [ -d ~/.rbenv/versions/#{ruby_version} ]; then echo 'true'; fi") == ''
           execute "rbenv install #{ruby_version}"
           execute "rbenv global #{ruby_version}"
           execute "rbenv rehash"
         end
         execute "gem install bundler"
         execute "rbenv rehash"
       end
       return
    end
   
    on roles(:sinatra, :db) do
      if "#{deploy_to}".include? "fresh"
        if capture("if [ -d ~/.rbenv ]; then echo 'true'; fi") == ''
          execute "git clone https://github.com/sstephenson/rbenv.git ~/.rbenv"
        else
          execute "cd ~/.rbenv && git pull"
        end
        if capture("if grep rbenv ~/.bashrc; then echo 'true'; fi") == ''
          execute "echo 'eval \"$(rbenv init -)\"' | cat - ~/.bashrc > tmp"
          execute "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' | cat - tmp > tmp1"
          execute "mv -f ~/tmp1 ~/.bashrc"
          execute "rm -f ~/tmp"
          execute ". ~/.bashrc"
        end
        if capture("if [ -d ~/.rbenv/plugins/ruby-build ]; then echo 'true'; fi") == ''
          execute "git clone https://github.com/sstephenson/ruby-build ~/.rbenv/plugins/ruby-build"
          execute "rbenv rehash"
        else
          execute "cd ~/.rbenv/plugins/ruby-build && git pull"
          execute "rbenv rehash"
        end
        if capture("if [ -d ~/.rbenv/versions/#{ruby_version} ]; then echo 'true'; fi") == ''
          execute "rbenv install #{ruby_version}"
          execute "rbenv global #{ruby_version}"
          execute "rbenv rehash"
        end
        execute "gem install bundler"
        execute "rbenv rehash"
      end
    end
  end
end 

require 'rbvmomi'
require 'thread'

class VmAccess
  @vim
  @vm_source  
  @server_list
  @env_list
  @threads
  def initialize(host,user,psd)
      @vm_source   = 'ubuntu14.04_template'
      @server_list = ['nginx','sinatra','db']
      @env_list    = ['staging','testing','production']
      @threads     = []
      connect_vcenter(host,user,psd)
  end #initialize
  
  def connect_vcenter(host,user,psd)
      @vim = RbVmomi::VIM.connect  host: host, user: user, password: psd, insecure: true 
  end #connect_vcenter

  def remove_vms(servers_json)
      puts 'Start to remove vms...'
      @env_list.each do | env |
         @server_list.each do | server |
          @threads << Thread.new do
           servers_json['servers'][env][server].map { | entity |
             vm = @vim.serviceInstance.find_datacenter.find_vm(entity['server_name'])
             if vm != nil 
              vm.PowerOffVM_Task.wait_for_completion
              vm.Destroy_Task.wait_for_completion    
              puts "'" + entity['server_name'].to_s + "' has been removed!"
             end                                     
           }
           sleep 1
          end #thread
         end
      end 
      @threads.each { |t| t.join }
      @threads.clear
      puts 'End removing vms...'
  end #remove_vms

  def create_vms(servers_json)
      puts 'Start to create vms...'
      @env_list.each do | env |
         @server_list.each do | server |
           @threads << Thread.new do
            servers_json['servers'][env][server].map { | entity |
             vm           = @vim.serviceInstance.find_datacenter.find_vm(@vm_source) or abort ("Source VM '" + @vm_source + "' Not Found!")         
             relocateSpec = RbVmomi::VIM.VirtualMachineRelocateSpec
             spec         = RbVmomi::VIM.VirtualMachineCloneSpec(:location => relocateSpec, :powerOn => true, :template => false)
             task         = vm.CloneVM_Task(:folder => vm.parent, :name => entity['server_name'], :spec => spec)
             task.wait_for_completion  
             puts "'" + entity['server_name'].to_s + "' has been created!"
            }
            sleep 1
           end #thread
         end
      end
      
      @threads.each { |t| t.join }      

      #Get IP address for each vm 
      puts 'Start to get IP address for each vms...'
      sleep 30
      @env_list.each do | env |
         @server_list.each do | server |
            servers_json['servers'][env][server].map { | entity |
              vm           = @vim.serviceInstance.find_datacenter.find_vm(entity['server_name']) or abort ("VM '" + entity['server_name'] + "' Not Found!")
              entity['ip'] = vm.guest_ip()   
              puts  "'" + entity['server_name'].to_s + "' IP is " + vm.guest_ip().to_s
            }
         end
      end  
      puts 'End creating mvs...'
  end #create_vms

end #vmAccess

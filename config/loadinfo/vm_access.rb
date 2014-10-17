require 'rbvmomi'
require 'thread'

class VmAccess
  @vim
  @vm_source  
  @server_list
  @env_list
  @threads
  def initialize(host,user,psd,datacenter,cluster,vm_template_source)
      @data_center  = datacenter
      @cluster_name = cluster
      @vm_source    = ['ubuntu14.04_template','Swift-Template-release']
      @server_list  = ['nginx','sinatra','db','swift','swift-nginx']
      @env_list     = ['fresh','testing']
      @threads      = []
      connect_vcenter(host,user,psd)
  end #initialize
  
  def connect_vcenter(host,user,psd)
      @vim = RbVmomi::VIM.connect  host: host, user: user, password: psd, insecure: true 
  end #connect_vcenter

  def get_biggest_datastore
      dc     = @vim.serviceInstance.find_datacenter(@data_center)
      ds     = dc.datastore[0]
      fs     = dc.datastore[0].info.freeSpace  #free space of the first storage.
      fs_tmp = nil
      dc.datastore.map { | store |
         fs_tmp = store.info.freeSpace
         if fs_tmp > fs and /datastore/.match(store.summary.name) == nil
            fs = fs_tmp
            ds = store
         end
      }
      return ds
  end # get_biggest_datastore

  def remove_vms(servers_json)
      puts 'Start to remove vms...'
      @env_list.each do | env |
         @server_list.each do | server |
          @threads << Thread.new do
           servers_json['servers'][env][server].map { | entity |
           # puts entity
             vm = @vim.serviceInstance.find_datacenter.find_vm(entity['server_name'])
             if vm != nil 
              # puts vm
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
             if server == 'swift'
                vm_source = @vm_source[1]
             else
                vm_source = @vm_source[0] 
             end   
             vm           = @vim.serviceInstance.find_datacenter.find_vm(vm_source) or abort ("Source VM '" + vm_source + "' Not Found!")         
             relocateSpec = RbVmomi::VIM.VirtualMachineRelocateSpec(:datastore => get_biggest_datastore(), :host => get_biggest_datastore().host[0].key )
             spec         = RbVmomi::VIM.VirtualMachineCloneSpec(:location => relocateSpec, :powerOn => false, :template => true)
             task         = vm.CloneVM_Task(:folder => vm.parent, :name => entity['server_name'], :spec => spec)
             task.wait_for_completion  
             puts "Template '" + entity['server_name'].to_s + "' has been created!"
            }
            sleep 1
           end #thread
         end
      end
      
      @threads.each { |t| t.join }

      #Convert template to vm      
      puts 'Start to convert template to vm...'
      @env_list.each do | env |
           @server_list.each do | server |
              servers_json['servers'][env][server].map { | entity |
               vm_new = @vim.serviceInstance.find_datacenter.find_vm( entity['server_name']) or  abort ("Template '" + entity['serr_name'] + "' Not Found!")
               vm_new.MarkAsVirtualMachine(:pool => @vim.serviceInstance.find_datacenter(@data_center).find_compute_resource([]).find(@cluster_name, RbVmomi::VIM::ClusterComputeResource).resourcePool)
               vm_new.PowerOnVM_Task.wait_for_completion
               puts "Convert template '" + entity['server_name'] + "' to vm successfully,and power it on"
              }
           end
      end
 
      #Get IP address for each vm 
      puts 'Start to get IP address for each vms...'
      sleep 500
      @env_list.each do | env |
         @server_list.each do | server |
            servers_json['servers'][env][server].map { | entity |
              vm           = @vim.serviceInstance.find_datacenter.find_vm(entity['server_name']) or abort ("VM '" + entity['server_name'] + "' Not Found!")
              entity['ip'] = vm.guest_ip().to_s   
              puts  "'" + entity['server_name'].to_s + "' IP is " + vm.guest_ip().to_s
            }
         end
      end  
      puts 'End creating mvs...'
  end #create_vms

end #vmAccess

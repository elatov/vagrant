# -*- mode: ruby -*-
# vi: set ft=ruby :
boxes = [
  { :name => :db,:role => 'db',:ip => '192.168.33.3',:ssh_port => 2202,:cpus => 1,:mem => 512 },
  { :name => :web,:role => 'web',:ip => '192.168.33.2',:ssh_port => 2201,:http_port => 8080,:cpus => 1, :mem => 512},
  ]

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    boxes.each do |opts|
        config.vm.define opts[:name] do |config|
    	    config.vm.box       = "elatov/opensuse13-64"
    	    config.vm.network  "private_network", ip: opts[:ip]
    	    config.vm.network  "forwarded_port", guest: 22, host: opts[:ssh_port]
    	    config.vm.network  "forwarded_port", guest: 80, host: opts[:http_port] if opts[:http_port]
    	    config.vm.hostname = "%s.vagrant" % opts[:name].to_s
    	    config.vm.synced_folder "~/stuff", "/vagrant"
	    config.vm.provider "virtualbox" do |vb|
  	    # Use VBoxManage to customize the VM. For example to change memory:
    	        vb.customize ["modifyvm", :id, "--cpus", opts[:cpus] ] if opts[:cpus]
    	        vb.customize ["modifyvm", :id, "--memory", opts[:mem] ] if opts[:mem] 
	    end
	    config.vm.provision "puppet" do |puppet|
                puppet.manifests_path = "manifests"
                puppet.manifest_file  = "%s.pp" % opts[:role].to_s
                #puppet.options = "--verbose --debug"
            end
       end
    end
end

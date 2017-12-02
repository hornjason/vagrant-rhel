# -*- mode: ruby -*-
# vi: set ft=ruby :

tower_static_ip = '192.168.110.226'
private_key = '~/.ssh/id_rsa'

boxes = [
    {
        :name  => "rhel7",
        :eth1  => tower_static_ip,
        :mem   => "2048",
        :vcpu  => "1",
        :default => true,
        :share => "/vagrant",
        :localdir => "~/projects",
      	:port => "9443",
	      :box => "rhel7.4",
	      :pool_id => ''
    }
]

required_plugins = %w( vagrant-env vagrant-hostmanager vagrant-vbguest vagrant-registration)
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

Vagrant.configure(2) do |config|
  boxes.each do |opts|
    config.vm.define opts[:name] ,primary: opts[:default] do |config|

    # Set machine size
    config.vm.provider :virtualbox do |vb|
	vb.name = opts[:name]
        vb.memory = 2048
        vb.cpus = 1
    	vb.linked_clone = true
    end

    # Hostname management
    config.vm.hostname = opts[:name]
    config.hostmanager.enabled = true
    config.hostmanager.manage_host = true
    config.hostmanager.manage_guest = true
    config.hostmanager.include_offline = true

    # Network
    config.vm.synced_folder opts[:localdir], opts[:share], type: "virtualbox"
    config.vm.network 'private_network', ip: opts[:eth1]
    config.vm.network :forwarded_port, guest: 443, host: opts[:port]

    # rhel box
    #rhel_string = "rhel redhat"
    config.vm.box = opts[:box]
    if opts[:box].include? 'rhel'
	    config.registration.username = ENV['SUB_USER']
	    config.registration.password = ENV['SUB_PASS']
	    config.registration.pools    = ENV['POOLID']
    end
#   TODO: Add RHN REPOSlist
#         install git wget tmux vim 
#         update bashrc with ssh-agent
#    # Ansible Tower configuration
#    config.vm.provision "ansible" do |ansible|
#        ansible.playbook = "playbook.yaml"
#    end

    end
  end
end

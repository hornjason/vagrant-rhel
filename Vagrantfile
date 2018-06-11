# -*- mode: ruby -*-
# vi: set ft=ruby :

static_ip = '192.168.110.230'
private_key = '~/.ssh/id_rsa'

boxes = [
    {
        :name  => "rhel7-test",
        :eth1  => static_ip,
        :mem   => "6144",
        :vcpu  => "1",
        :default => true,
        :share => "/vagrant",
        :localdir => "~/projects",
      	:port => "9443",
        :box => "jasonhorn/rhel7",
    }
]

$clean_ssh_sock = <<SCRIPT

[ -a /home/vagrant/.ssh/ssh_auth_sock ] && rm -rf /home/vagrant/.ssh/ssh_auth_sock
[ -a /root/.ssh/ssh_auth_sock ] && rm -rf /root/.ssh/ssh_auth_sock
SCRIPT

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
        vb.memory = opts[:mem]
        vb.cpus = opts[:vcpu]
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
#    config.vm.network :forwarded_port, guest: 443, host: opts[:port]

    # rhel box
    #rhel_string = "rhel redhat"
    config.vm.box = opts[:box]
    if opts[:box].include? 'rhel'
      # orgi ID / activation-key
	    config.registration.username = ENV['SUB_USER']
	    config.registration.password = ENV['SUB_PASS']
	    config.registration.pools    = ENV['POOLID']
    end

     config.vm.provision "shell", path: "setup.sh"
     config.vm.provision "shell", inline: $clean_ssh_sock, run: "always"

#    # Ansible Tower configuration
#    config.vm.provision "ansible" do |ansible|
#        ansible.playbook = "playbook.yaml"
#    end

    end
  end
end

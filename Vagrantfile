# -*- mode: ruby -*-
# vi: set ft=ruby :

static_ip = '192.168.110.215'
private_key = '~/.ssh/id_rsa'

boxes = [
    {
        :name  => "rhel7-cloud",
        :eth1  => static_ip,
        :mem   => "6144",
        :vcpu  => "1",
        :default => true,
        :share => "/vagrant",
        :localdir => "~/projects",
      	:port => "9443",
        #:box => "jasonhorn/rhel7",
        :box => "generic/rhel7",
    }
]

$clean_ssh_sock = <<SCRIPT
if [ -a /home/vagrant/.ssh/ssh_auth_sock ];then
  rm -rf /home/vagrant/.ssh/ssh_auth_sock
elif [ -a /root/.ssh/ssh_auth_sock ] ; then
  rm -rf /root/.ssh/ssh_auth_sock
fi
SCRIPT

$rhsm_script = %{
if ! subscription-manager status; then
  sudo subscription-manager register --username #{ENV['SUB_USER']} --password #{ENV['SUB_PASS']}
  sudo subscription-manager attach --pool #{ENV['POOLID']}
  sudo subscription-manager repos --disable rhel-7-server-htb-rpms
fi
}

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

    # Network #, type: "virtualbox"
    config.vm.synced_folder opts[:localdir], opts[:share]  #, type: "virtualbox"
    config.vm.network 'private_network', ip: opts[:eth1]
#    config.vm.network :forwarded_port, guest: 443, host: opts[:port]

    #config.ssh.username = 'cloud-user'
    # rhel box
    #rhel_string = "rhel redhat"
    config.vm.box = opts[:box]
    #if opts[:box].include? 'rhel'
      # orgi ID / activation-key
	  config.registration.username = ENV['SUB_USER']
	  config.registration.password = ENV['SUB_PASS']
	  config.registration.pools    = ENV['POOLID']

    #end
    config.vm.provision "shell", inline: $clean_ssh_sock, run: "always"
    config.vm.provision "shell", inline: $rhsm_script, run: "always"
    config.vm.provision "shell", path: "setup.sh"
#    config.trigger.before :destroy do |trigger|
#      trigger.warn = "Unregistering from RHSM"
      #trigger.run_remote "sudo subscription-manager unregister"
#      trigger.run_remote =  {inline: "sudo subscription-manager unregister"}
      #trigger.on_error =  "Something went wrong, please remove the machine manually from https://access.redhat.com/management/subscriptions"
#    end
#    # Ansible Tower configuration
#    config.vm.provision "ansible" do |ansible|
#        ansible.playbook = "playbook.yaml"
#    end

    end
  end
end

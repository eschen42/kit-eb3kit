# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "puppetlabs/debian-8.2-64-puppet"
  config.vm.box_url = "https://atlas.hashicorp.com/puppetlabs/boxes/debian-8.2-64-puppet"

  config.vm.hostname = "liferaydev"
  config.vm.network :forwarded_port, guest: 8080, host: 8894

  config.vm.provision "puppet" do |puppet|
     puppet.environment_path = "puppetenv"
     puppet.environment = "defaultenv"
     puppet.module_path = "modules"  
  end


  config.vm.provider :virtualbox do |vb, override|
    vb.customize ["modifyvm", :id,
        "--name", "liferaydev",
        "--memory", "2048"]
  end

end

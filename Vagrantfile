# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  #################################################
  ###    ADD YOUR CUSTOM CONFIGURATION BELOW    ###
  #################################################
  
  
  # Base url the bibbox kit (should match puppet config file)
  bibboxbaseurl = "eb3kit.bibbox.org"
  
  # Number of assigned CPU cores
  cpus = 4
  
  # Total amount of memory (RAM)
  memory = "8192"
  
  # Amount of additional disk space (hard drive)
  disksize = 301 * 1024   # 301 GB

   # Static IP and port within the host's network
  ip = "192.168.10.10"
  port = 1080
  
  
  #################################################
  ###        END OF CUSTOM CONFIGURATION        ###
  #################################################
  
  
  # - # - # - # - # - # - # - # - # - # - # - # - #
  
  
  #################################################
  ###  DO NOT EDIT THIS FILE BEYOND THIS POINT  ###
  #################################################
  
  
  # OS image image of the virtual machine
  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"

  # Static IP and port within the host's network
  config.vm.network :private_network, ip: ip
  config.vm.network :forwarded_port, host: port,  guest: 80
  
  # Port forwarding for SSH
  config.vm.network :forwarded_port, guest: 22, host: 2230, id: "ssh", disabled: true
  config.vm.network :forwarded_port, guest: 22, host: 2231, auto_correct: true

  # Start of provisioning
  config.vm.provider "virtualbox" do |vb|
  
    # Set RAM and CPUs of VM
    vb.memory = memory
    vb.cpus = cpus
    
    # Create new disk of size 301GB
    file_to_disk = File.realpath( "." ).to_s + "/disk-300GB.vdi"

        if ARGV[0] == "up" && ! File.exist?(file_to_disk) 
           puts "Creating 300GB disk #{file_to_disk}."
           vb.customize [
                'createhd', 
                '--filename', file_to_disk, 
                '--format', 'VDI', 
                '--size', disksize
                ] 
           vb.customize [
                'storageattach', bibboxbaseurl, 
                '--storagectl', 'IDE Controller', 
                '--port', 1, '--device', 0, 
                '--type', 'hdd', '--medium', 
                file_to_disk
                ]
        end

    vb.name = bibboxbaseurl
  end

  # Provision the VM with several puppet modules, add additional disk space and download Liferay if it doesn't exist yet
  config.vm.provision "shell", inline: <<-SHELL
    sudo bash /vagrant/resources/add_disk.sh
    sudo cp /vagrant/resources/liferay /etc/logrotate.d/
    mkdir -p /etc/puppetlabs/code/modules
    cp -r /vagrant/modules/* /etc/puppetlabs/code/modules
    if [ ! -f "/opt/liferay-ce-portal-tomcat-7.0-ga3.zip" ]; then
      echo "Downloading Liferay, this might take a while...";
      wget -nc -nv -P /opt/ "http://downloads.bibbox.org/liferay-ce-portal-tomcat-7.0-ga3.zip";
    else
      echo "Liferay sources already exist. Skipping download.";
    fi
    puppet module install puppetlabs-stdlib --version 4.14.0 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppetlabs-apt --version 2.3.0 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppetlabs-ntp --version 6.0.0 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppetlabs-firewall --version 1.8.1 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppetlabs-apache --version 1.11.0 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppet-archive --version 1.2.0 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppetlabs-vcsrepo --version 1.5.0 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppet-alternatives --version 1.0.2 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppetlabs-docker_platform --version 2.1.0 --modulepath /etc/puppetlabs/code/modules
    puppet module install puppetlabs-postgresql --version 4.8.0 --modulepath /etc/puppetlabs/code/modules
    puppet module install tylerwalts-jdk_oracle --version 1.5.0 --modulepath /etc/puppetlabs/code/modules
    sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 7F438280EF8D349F
    sudo apt-get update
    sudo apt-get install -y inotify-tools
    sudo apt-get install -y python3-pip
  SHELL

  config.vm.provision "puppet" do |puppet|
    puppet.facter = {
      "fqdn" => bibboxbaseurl
    }

    puppet.environment = "production"
    puppet.environment_path = "environments"
  end

  # To avoid the Warning: Could not retrieve fact fqdn
  config.vm.hostname = bibboxbaseurl

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end

# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  
  # Shared folders
  # config.vm.synced_folder "shared/opt", "/opt"
  # config.vm.synced_folder "shared/docker", "/var/lib/docker"

  # Base url the bibbox kit (should be same as in puppet config file)
  bibboxbaseurl = "eb3kit.bibbox.org"

  config.vm.box = "puppetlabs/ubuntu-14.04-64-puppet"

  #Webserver
  config.vm.network :forwarded_port, host: 1080,  guest: 80

  #Tomcat - Liferay
  config.vm.network :forwarded_port, host: 18080, guest: 8080
  config.vm.network :forwarded_port, host: 18000, guest: 8000
  config.vm.network :forwarded_port, host: 18081, guest: 8081
  
  config.vm.network :private_network, ip: "192.168.10.10"

  config.vm.network :forwarded_port, guest: 22, host: 2230, id: "ssh", disabled: true
  config.vm.network :forwarded_port, guest: 22, host: 2231, auto_correct: true

  config.vm.provider "virtualbox" do |vb|
  
    # (Option 1) Customize the amount of memory and the cpu cores of the VM:
    # vb.memory = "10240"
    # vb.cpus = 3
     
    # (Option 2) RECOMMENDED APPROACH: Give VM 1/4 system memory & access to all cpu cores on the host
    host = RbConfig::CONFIG['host_os']

    if host =~ /darwin/
      vb.cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      vb.memory = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    elsif host =~ /linux/
      vb.cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      vb.memory = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks, I can't help you
      vb.cpus = 4
      vb.memory = 4096
    end
    
    # Create new disk
    file_to_disk = File.realpath( "." ).to_s + "/disk.vdi"

        if ARGV[0] == "up" && ! File.exist?(file_to_disk) 
           puts "Creating 30GB disk #{file_to_disk}."
           vb.customize [
                'createhd', 
                '--filename', file_to_disk, 
                '--format', 'VDI', 
                '--size', 300000 * 1024 # 30 GB
                ] 
           vb.customize [
                'storageattach', :id, 
                '--storagectl', 'IDE Controller', 
                '--port', 1, '--device', 0, 
                '--type', 'hdd', '--medium', 
                file_to_disk
                ]
        end

    vb.name = bibboxbaseurl
  end

  # Provision the VM with several puppet modules
  config.vm.provision "shell", inline: <<-SHELL
    sudo bash /vagrant/resources/add_disk.sh
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
    # puppet.manifests_path = "manifests"
    # puppet.manifest_file = "default.pp"
    # puppet.module_path = "modules"
    # puppet.options = "--hiera_config /vagrant/hiera.yaml --verbose --debug"
    # puppet.options = "--hiera_config /vagrant/hiera.yaml"
  end

  # To avoid the Warning: Could not retrieve fact fqdn
  config.vm.hostname = bibboxbaseurl

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end

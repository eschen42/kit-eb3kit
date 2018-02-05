#!/bin/sh

# Run on VM to bootstrap Puppet Agent nodes
# https://puppet.com/docs/puppet/4.9/install_linux.html



wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo apt-get update -q
sudo apt-get install -q -y systemd
sudo apt-get install -q -y puppet-agent
sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

echo "Environment PATH $PATH"

echo $PATH | grep -q "/opt/puppetlabs/bin"

if [ $? -eq 0 ]; then
  export $PATH=/opt/puppetlabs/bin:$PATH
  echo "new PATH: $PATH" 
fi



#!/bin/bash

# run the script curl .... | sudo bash -s arg1 arg2

echo "Installing BIBBOX Server"

apt-get install -y git

DIRECTORY="/vagrant"
if [ ! -d "$DIRECTORY" ]; then
  echo "Coning KIT Repository"
  git clone https://github.com/bibbox/kit-eb3kit.git /vagrant
fi

echo "Install Python and Tools"
/vagrant/install-pyhthon-and-tools.sh
echo "download Liferay"
/vagrant/download-liferay.sh
echo "Install Puppet"
/vagrant/bootstrap-puppet-agent.sh
echo "Install Puppet modules"
/vagrant/install-base-puppet-modules.sh

echo "Run Puppet"
puppet 
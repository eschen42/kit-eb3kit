#!/bin/bash

# run the script curl https://raw.githubusercontent.com/bibbox/kit-eb3kit/master/install-bibbox-server.sh | sudo bash

# curl https://raw.githubusercontent.com/bibbox/kit-eb3kit/master/install-bibbox-server.sh | sudo bash -s arg1 arg2

echo " --- Installing BIBBOX Server"

chmod +x /vagrant/*.sh
apt-get install -y git
mkdir /vagrant/modules/

DIRECTORY="/vagrant"
if [ ! -d "$DIRECTORY" ]; then
  echo " --- Coning KIT Repository"
  git clone https://github.com/bibbox/kit-eb3kit.git /vagrant
else
  echo " --- Update Kit git Repository"
  git -C /vagrant/ pull
fi

echo " --- Install Python and Tools"
/vagrant/install-pyhthon-and-tools.sh
echo " --- download Liferay"
/vagrant/download-liferay.sh
echo " --- Install Puppet"
/vagrant/bootstrap-puppet-agent.sh
echo " --- Install Puppet modules"
/vagrant/install-base-puppet-modules.sh

echo " --- Run Puppet"
if [ $? ]; then
  export PATH=/opt/puppetlabs/bin:$PATH
  echo "new PATH: $PATH"
fi
puppet apply --modulepath=/vagrant/modules -L /vagrant/environments/production/manifests/config.pp /vagrant/modules/vmbuilder/manifests/init.pp
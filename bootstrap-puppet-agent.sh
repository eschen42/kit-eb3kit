#!/bin/sh

# Run on VM to bootstrap Puppet Agent nodes
# https://puppet.com/docs/puppet/4.9/install_linux.html

echo "##########################################################################################"
echo "#                                  PUPPET AGENT                                          #"
echo "##########################################################################################"

if [ ! -f puppetlabs-release-pc1-xenial.deb ]; then
  wget https://apt.puppetlabs.com/puppetlabs-release-pc1-xenial.deb
fi
sudo dpkg -i puppetlabs-release-pc1-xenial.deb
sudo dpkg --configure -a
(
  (dpkg --status systemd > /dev/null) && (dpkg --status puppet-module-puppetlabs-postgresql > /dev/null)
) || (
  sudo apt-get update -q
  sudo apt-get install -q -y systemd
  #sudo apt-get install -q -y puppet-agent
  sudo apt-get install -q -y puppet-module-puppetlabs-postgresql
)
find . -type f -print | xargs grep -l /opt/puppetlabs/bin/puppet | grep -v bootstrap-puppet-agent.sh | xargs sed -i -e 's./opt/puppetlabs/bin/puppet.puppet.g'
sudo puppet resource service puppet ensure=running enable=true

sudo systemctl status puppet.service | cat
# sudo systemctl enable puppet.service
# sudo systemctl start puppet.service
# sudo systemctl status puppet.service | cat
#
# sudo puppet resource service puppet ensure=running

echo "Environment PATH $PATH"

echo $PATH | grep -q "/opt/puppetlabs/bin"

if [ $? ]; then
  export PATH=/opt/puppetlabs/bin:$PATH
  echo "new PATH: $PATH" 
fi



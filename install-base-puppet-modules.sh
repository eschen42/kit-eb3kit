#!/bin/bash

echo "install puppet modules"

if [ $? ]; then
  export PATH=/opt/puppetlabs/bin:$PATH
  echo "new PATH: $PATH"
fi


puppet module install puppetlabs-stdlib --version 4.14.0  --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-apt --version 2.3.0      --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-ntp --version 6.0.0      --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-firewall --version 1.8.1 --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-apache --version 1.11.0  --modulepath /etc/puppetlabs/code/modules
puppet module install puppet-archive --version 1.2.0      --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-vcsrepo --version 1.5.0  --modulepath /etc/puppetlabs/code/modules
puppet module install puppet-alternatives --version 1.0.2 --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-docker_platform --version 2.1.0 --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-postgresql --version 4.8.0 --modulepath /etc/puppetlabs/code/modules
puppet module install tylerwalts-jdk_oracle --version 2.0.0 --modulepath /etc/puppetlabs/code/modules
#
# finaly copy our modules to the /etc/puppetlabs/code/modules
#
echo "copy BIBBOX puppet modules"
cp -r /vagrant/modules/* /etc/puppetlabs/code/modules

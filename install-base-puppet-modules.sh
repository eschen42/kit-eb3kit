#!/bin/bash


echo "##########################################################################################"
echo "#                                  PUPPET MODULES                                        #"
echo "##########################################################################################"

/opt/puppetlabs/bin/puppet module install puppetlabs-stdlib --version 4.14.0  --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppetlabs-apt --version 2.3.0      --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppetlabs-ntp --version 6.0.0      --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppetlabs-firewall --version 1.8.1 --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppetlabs-apache --version 1.11.0  --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppet-archive --version 1.2.0      --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppetlabs-vcsrepo --version 1.5.0  --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppet-alternatives --version 1.0.2 --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppetlabs-docker_platform --version 2.1.0 --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install puppetlabs-postgresql --version 4.8.0 --modulepath /etc/puppetlabs/code/modules
/opt/puppetlabs/bin/puppet module install tylerwalts-jdk_oracle --version 2.0.0 --modulepath /etc/puppetlabs/code/modules

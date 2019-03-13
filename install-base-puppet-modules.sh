#!/bin/bash


echo "##########################################################################################"
echo "#                                  PUPPET MODULES                                        #"
echo "##########################################################################################"

lsb_release -sd | grep 'Ubuntu 1[68][.]' || (
  echo "Script '$0' only works for Ubuntu 16 (xenial xerus) or 18 (bionic beaver)"
  lsb_release -a
  exit 78 # "configuration error" per /usr/include/sysexits.h
)

puppet module install puppetlabs-stdlib --version 4.14.0  --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-apt --version 2.3.0      --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-ntp --version 6.0.0      --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-firewall --version 1.8.1 --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-apache --version 1.11.0  --modulepath /etc/puppetlabs/code/modules
puppet module install puppet-archive --version 1.2.0      --modulepath /etc/puppetlabs/code/modules
puppet module install puppetlabs-vcsrepo --version 1.5.0  --modulepath /etc/puppetlabs/code/modules
puppet module install puppet-alternatives --version 1.0.2 --modulepath /etc/puppetlabs/code/modules
lsb_release -sd | grep 'Ubuntu 18[.]' && puppet module install puppetlabs-docker --version 3.4.0 --modulepath /etc/puppetlabs/code/modules
lsb_release -sd | grep 'Ubuntu 16[.]' && puppet module install puppetlabs-docker_platform --version 2.1.0 --modulepath /etc/puppetlabs/code/modules

lsb_release -sd | grep 'Ubuntu 18[.]' && puppet module install puppetlabs-postgresql --version 5.6.0 --modulepath /etc/puppetlabs/code/modules
lsb_release -sd | grep 'Ubuntu 16[.]' && puppet module install puppetlabs-postgresql --version 4.8.0 --modulepath /etc/puppetlabs/code/modules

puppet module install tylerwalts-jdk_oracle --version 2.0.0 --modulepath /etc/puppetlabs/code/modules

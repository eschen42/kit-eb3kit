#!/bin/bash


echo "##########################################################################################"
echo "#                                  PUPPET MODULES                                        #"
echo "##########################################################################################"

lsb_release -sd | grep 'Ubuntu 1[68][.]' || (
  echo "Script '$0' only works for Ubuntu 16 (xenial xerus) or 18 (bionic beaver)"
  lsb_release -a
  exit 78 # "configuration error" per /usr/include/sysexits.h
)

lsb_release -sd | grep 'Ubuntu 18[.]' && (
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-translate  --version 1.2.0
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-stdlib     --version 5.1.0
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-apt        --version 6.2.1
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-powershell --version 2.2.0
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-reboot     --version 2.1.2
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-docker     --version 3.4.0
  puppet module --modulepath /etc/puppetlabs/code/modules install stahnma-epel          --version 1.3.1
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-ntp        --version 7.4.0
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-firewall   --version 1.15.1
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-concat     --version 5.3.0
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-apache     --version 4.0.0
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-vcsrepo    --version 2.4.0
  puppet module --modulepath /etc/puppetlabs/code/modules install puppetlabs-postgresql --version 5.12.1
  puppet module --modulepath /etc/puppetlabs/code/modules install puppet-alternatives   --version 3.0.0
  puppet module --modulepath /etc/puppetlabs/code/modules install puppet-archive        --version 3.2.1
  puppet module --modulepath /etc/puppetlabs/code/modules install tylerwalts-jdk_oracle --version 2.0.0
)

lsb_release -sd | grep 'Ubuntu 16[.]' && (
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppetlabs-stdlib          --version 4.14.0
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppetlabs-apt             --version 2.3.0
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppetlabs-ntp             --version 6.0.0
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppetlabs-firewall        --version 1.8.1
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppetlabs-apache          --version 1.11.0
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppet-archive             --version 1.2.0
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppetlabs-vcsrepo         --version 1.5.0
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppet-alternatives        --version 1.0.2
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppetlabs-docker_platform --version 2.1.0
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall puppetlabs-postgresql      --version 4.8.0
  puppet module  --modulepath /etc/puppetlabs/code/modulesinstall tylerwalts-jdk_oracle      --version 2.0.0
)

# vim: sw=2 ts=2 et ai :

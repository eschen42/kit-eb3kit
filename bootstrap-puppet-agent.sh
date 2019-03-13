#!/bin/bash

# Run on VM to bootstrap Puppet Agent nodes
# https://puppet.com/docs/puppet/4.9/install_linux.html

# get source directory - ref: https://stackoverflow.com/a/246128
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # resolve relative symlinks
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
pushd $DIR

echo "##########################################################################################"
echo "#                                  PUPPET AGENT                                          #"
echo "##########################################################################################"

lsb_release -sd | grep 'Ubuntu 1[68][.]' || (
  echo "Script '$0' only works for Ubuntu 16 (xenial xerus) or 18 (bionic beaver)"
  lsb_release -a
  exit 78 # "configuration error" per /usr/include/sysexits.h
)

# Inspiration for code below: https://computingforgeeks.com/how-to-setup-puppet-master-and-agent-ubuntu-18-04-bionic-beaver/
PUPPET_DEB=none
lsb_release -sd | grep 'Ubuntu 18[.]' && PUPPET_DEB=puppet-release-bionic.deb
lsb_release -sd | grep 'Ubuntu 16[.]' && PUPPET_DEB=puppetlabs-release-pc1-xenial.deb
if [ ! -f ${PUPPET_DEB} ]; then
  wget https://apt.puppetlabs.com/${PUPPET_DEB}
fi
echo Check installation status for package 'puppet-release'.
(dpkg --status puppet-release | grep Status | tee >(cat 1>&2) | grep 'Status: install ok installed') || (
  sudo dpkg -i ${PUPPET_DEB}
  sudo dpkg --configure -a
)
sudo apt-get update -q
echo Check installation status for package 'systemd'.
(dpkg --status systemd | grep Status | tee >(cat 1>&2) | grep 'Status: install ok installed') || sudo apt-get install -y systemd
echo Check installation status for package 'puppetmaster'.
(dpkg --status puppetmaster | grep Status | tee >(cat 1>&2) | grep 'Status: install ok installed') || sudo apt-get install -y puppetmaster
echo Check installation status for package 'puppet-module-puppetlabs-postgresql'.
(dpkg --status puppet-module-puppetlabs-postgresql | grep Status | tee >(cat 1>&2) | grep 'Status: install ok installed') || sudo apt-get install -y puppet-module-puppetlabs-postgresql
find . -type f -print | xargs grep -l /opt/puppetlabs/bin/puppet | grep -v bootstrap-puppet-agent.sh | xargs sed -i -e 's./opt/puppetlabs/bin/puppet.puppet.g'

# hack to get puppet to find puppet-master listening to port 8140 on local machine
ping -c 1 puppet > /dev/null || sudo bash -c 'echo 127.0.2.1 puppet>> /etc/hosts'
ping -c 1 puppet > /dev/null || (
  echo "Aborting because I cannot resolve the name 'puppet'"
  exit 78 # "configuration error" in /usr/include/sysexits.h
)
sudo systemctl start puppet-master.service
sudo systemctl status puppet-master.service | cat

#sudo puppet resource service puppet ensure=running enable=true   --debug --verbose
sudo puppet resource service puppet ensure=running enable=true

sudo systemctl status puppet.service | cat
# sudo systemctl enable puppet.service
# sudo systemctl start puppet.service
# sudo systemctl status puppet.service | cat
#
# sudo puppet resource service puppet ensure=running

# puppet is installed at /usr/bin/puppet, so the PATH does not need to be manipulated

# echo "Environment PATH $PATH"
#
# echo $PATH | grep -q "/opt/puppetlabs/bin"
#
# if [ $? ]; then
#   export PATH=/opt/puppetlabs/bin:$PATH
#   echo "new PATH: $PATH"
# fi



#!/bin/bash

# run the script curl https://raw.githubusercontent.com/bibbox/kit-eb3kit/master/install-bibbox-server.sh | sudo bash

# curl --silent https://raw.githubusercontent.com/bibbox/kit-eb3kit/master/install-bibbox-server.sh | sudo bash -url local.test.box -gui

# bash <(curl --silent https://raw.githubusercontent.com/bibbox/kit-eb3kit/master/install-bibbox-server.sh) -url local.test.box -gui

# wget -qO- https://raw.githubusercontent.com/bibbox/kit-eb3kit/master/install-bibbox-server.sh | sudo bash -s -- -url local.test.box -gui

# BIBBOX Version
# wget -qO- https://raw.githubusercontent.com/bibbox/kit-eb3kit/master/install-bibbox-server.sh | sudo bash -s -- -url eb3kit.bibbox.org

echo " --- Installing BIBBOX Server"

#---------------------------------
url=lab.box
gui=false
while [ "$1" != "" ]; do
    case $1 in
        -url | --base-url )     shift
								url=$1
                                ;;
        -gui | --install-gui )  gui=true
                                ;;
        * )                     usage
                                error_exit "Parameters not matching"
    esac
    shift
done

#---------------------------------
echo "Install GIT"
apt-get install -y git
mkdir /vagrant/modules/

#---------------------------------
DIRECTORY="/vagrant"
if [ ! -d "$DIRECTORY" ]; then
  echo " --- Coning KIT Repository"
  git clone https://github.com/bibbox/kit-eb3kit.git /vagrant
else
  echo " --- Update Kit git Repository"
  git -C /vagrant/ pull
fi
chmod +x /vagrant/*.sh

sed -i "s/eb3kit.bibbox.org/$url/g" /vagrant/environments/production/manifests/config.pp
 
#---------------------------------
echo " --- Install Python and Tools"
/vagrant/install-pyhthon-and-tools.sh
echo " --- download Liferay"
/vagrant/download-liferay.sh
echo " --- Install Puppet"
/vagrant/bootstrap-puppet-agent.sh
echo " --- Install Puppet modules"
/vagrant/install-base-puppet-modules.sh

#---------------------------------
echo " --- Run Puppet"
if [ $? ]; then
  export PATH=/opt/puppetlabs/bin:$PATH
  echo "new PATH: $PATH"
fi
puppet apply --modulepath=/etc/puppetlabs/code/modules  /vagrant/environments/production/manifests/config.pp 

if [ "$gui" = true ] ; then
    echo " --- Install GUI"
	/vagrant/install-gui.sh
fi

echo " --- Run liferay setup"
#service bibbox start

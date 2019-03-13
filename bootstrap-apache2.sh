#!/bin/bash
echo "##########################################################################################"
echo "#                                  APACHE2                                               #"
echo "##########################################################################################"


(
  dpkg --status apache2 > /dev/null
) || (
  sudo apt-get update -q
  sudo apt-get install -q -y apache2
)

# enable the proxy module
if [ ! -e /etc/apache2/mods-enabled/proxy.conf ]; then 
  sudo a2enmod -q proxy
  sudo systemctl restart apache2
fi

# create required directory if it does not exist
if [ ! -d /etc/apache2/conf.d ]; then 
  sudo mkdir /etc/apache2/conf.d
fi

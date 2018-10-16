#!/bin/bash


# sudo git clone https://github.com/bibbox/kit-eb3kit.git /opt/bibbox-install
# sudo chmod +x /opt/bibbox-install/*.sh
# sudo /opt/bibbox-install/install-bibbox-local.sh -url put.here.your.domain -gui
#
# sudo git -C  /opt/bibbox-install pull


echo "##########################################################################################"
echo "#                                  BIBBOX INSTALLER                                      #"
echo "##########################################################################################"

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

##################################################################
#                   checking locale                              #
##################################################################

if [ -n "$LANG" ];
then
    echo   "your default language is ${LANG}"
else
    echo LANG="en_US.UTF-8"
fi
LANGUAGE=${LANG}
LC_ALL=${LANG}
echo  "your locale is"
locale



##################################################################
#                    bootstrap the machine                       #
##################################################################

/opt/bibbox-install/install-pyhthon-and-tools.sh
/opt/bibbox-install/download-liferay.sh
/opt/bibbox-install/bootstrap-puppet-agent.sh
/opt/bibbox-install/install-base-puppet-modules.sh

##################################################################
#                    lets dance with puppet                      #
##################################################################

sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_ubuntu.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_packages.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_files.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_services.pp


/opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_ubuntu.pp
/opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_packages.pp
/opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_files.pp
/opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_services.pp

##################################################################
#       optionally install the ubuntu desktop und dnsmasq        #
##################################################################

if [ "$gui" = true ] ; then
    apt-get install -y ubuntu-desktop
    apt-get install -y dnsmasq

    sed -i "s/enabled=1/enabled=0/g" /etc/default/apport
    service apport restart

    sed -i "s|#conf-dir=/etc/dnsmasq.d/,\*.conf|conf-dir=/etc/dnsmasq.d/,*.conf|g" /etc/dnsmasq.conf
    sed -i '1i127.0.0.1 $url' /etc/hosts
    
    echo "address=/$url/127.0.0.1" > /etc/dnsmasq.d/bibbox-local.conf
fi

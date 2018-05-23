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
#                    bootstrap the machine                       #
##################################################################

/opt/bibbox-install/install-pyhthon-and-tools.sh
/opt/bibbox-install/download-liferay.sh
/opt/bibbox-install/bootstrap-puppet-agent.sh
/opt/bibbox-install/install-base-puppet-modules.sh

##################################################################
#                    lety dance with puppet                      #
##################################################################

sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_ubuntu.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_packages.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_files.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_services.pp


/opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_ubuntu.pp
/opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_packages.pp
/opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_files.pp
/opt/puppetlabs/bin/puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_services.pp


if [ "$gui" = true ] ; then
	/opt/bibbox-install/install-gui.sh
fi

#!/bin/bash


# sudo git clone https://github.com/bibbox/kit-eb3kit.git /opt/bibbox-install
# sudo chmod +x /opt/bibbox-install/*.sh
# sudo /opt/bibbox-install/install-bibbox-local.sh -url put.here.your.domain -gui
#
# sudo git -C  /opt/bibbox-install pull


echo "##########################################################################################"
echo "#                                  BIBBOX INSTALLER                                      #"
echo "##########################################################################################"

if [ "$(whoami)" != "root" ]; then
  echo "You must run install-bibbox-local.sh as root or run it with sudo (as root)."
  exit 1
fi

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

cat > /etc/profile.d/locale_en_US.sh << EOF
LANG="en_US.UTF-8"
LANGUAGE="en_US:en"
export LC_ALL=en_US.UTF-8
EOF

#source /etc/profile.d/locale_en_US.sh

LANG=${LANG:-en_US.UTF-8}
LANGUAGE=${LANGUAGE:-en_US:en}
if [ -n "$LANG" ];
then
    echo   "your default language is ${LANG}"
else
    echo LANG="en_US.UTF-8"
fi
export LC_ALL=${LANG}
echo  "your locale is"
sudo locale

# echo each command as it is executed by the shell
set -x

##################################################################
#                    back up apache2 config                      #
##################################################################

tar cvfz /etc/apache2-$(date -u '+%Y%m%dT%H%M%SZ').tgz /etc/apache2

##################################################################
#                    bootstrap the machine                       #
##################################################################

bash /opt/bibbox-install/bootstrap-apache2.sh

bash /opt/bibbox-install/install-pyhthon-and-tools.sh
bash /opt/bibbox-install/download-liferay.sh
bash /opt/bibbox-install/bootstrap-puppet-agent.sh
bash /opt/bibbox-install/install-base-puppet-modules.sh

##################################################################
#                    lets dance with puppet                      #
##################################################################

sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_ubuntu.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_postgres.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_packages.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_files.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/local/manifests/config_services.pp

sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/modules/vmbuilder/manifests/init.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/environments/production/manifests/config.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/modules-local/vmbuilder_ubuntu/manifests/init.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/modules-local/vmbuilder_packages/manifests/init.pp
sed -i "s/eb3kit.bibbox.org/$url/g"  /opt/bibbox-install/modules-local/vmbuilder_files/manifests/init.pp


puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_ubuntu.pp
puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_packages_postgres.pp
puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_packages.pp
puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_files.pp

puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  /opt/bibbox-install/environments/local/manifests/config_services.pp
puppet apply --modulepath=/etc/puppetlabs/code/modules:/opt/bibbox-install/modules-local  --debug --verbose /opt/bibbox-install/environments/local/manifests/config_services_liferay.pp

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

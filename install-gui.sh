#!/bin/bash

echo "BIBBOX INSTALLER - install GUI"

apt-get install -y ubuntu-desktop
apt-get install -y dnsmasq

sed -i "s/enabled=1/enabled=0/g" /etc/default/apport
service apport restart


sed -i "s|#conf-dir=/etc/dnsmasq.d/,*.conf|conf-dir=/etc/dnsmasq.d/,*.conf|g" /etc/dnsmasq.conf
echo "address=/*.$url/127.0.0.1" > /etc/dnsmasq.d/bibbox-local.conf

# /etc/dnsmasq.conf address=/*.$url/???.???.???.???
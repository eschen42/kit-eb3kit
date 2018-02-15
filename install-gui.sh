#!/bin/bash

echo "Install GUI"

apt-get install -y ubuntu-desktop
apt-get install -y dnsmasq

sed -i "s/enabled=1/enabled=0/g" /etc/default/apport
service apport restart

# /etc/dnsmasq.conf address=/*.$url/???.???.???.???


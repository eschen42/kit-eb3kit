#!/bin/bash

echo "##########################################################################################"
echo "#                                  Get Puppet release key                                #"
echo "##########################################################################################"

sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 7F438280EF8D349F

echo "##########################################################################################"
echo "#                                  python 3 and some tools                               #"
echo "##########################################################################################"

sudo apt-get update
sudo apt-get install -y inotify-tools
sudo apt-get install -y python3-pip

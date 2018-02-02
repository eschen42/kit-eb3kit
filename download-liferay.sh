#!/bin/bash

echo "pre-download liferay"

if [ ! -f "/opt/liferay-ce-portal-tomcat-7.0-ga3.zip" ]; then
    if [ ! -f "/vagrant/liferay-ce-portal-tomcat-7.0-ga3.zip" ]; then
            echo "Copying Liferay,";
            cp /vagrant/liferay-ce-portal-tomcat-7.0-ga3.zip /opt/
        else
            echo "Downloading Liferay, this might take a while...";
            wget -nc -nv -P /opt/ "http://downloads.bibbox.org/liferay-ce-portal-tomcat-7.0-ga3.zip";
        fi        
else
  echo "Liferay sources already exist";    
fi
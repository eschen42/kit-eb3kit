#!/bin/bash



echo "##########################################################################################"
echo "#                                DOWNLOAD LIFERAY                                        #"
echo "##########################################################################################"

if [ ! -f "/opt/liferay-ce-portal-tomcat-7.0-ga3.zip" ]; then
   echo "BIBBOX INSTALLER - downloading Liferay, this might take a while...";
   wget -nc -nv -P /opt/ "http://downloads.bibbox.org/liferay-ce-portal-tomcat-7.0-ga3.zip";
else
   echo "BIBBOX INSTALLER - liferay sources already exist";
fi

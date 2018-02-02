#!/bin/bash

echo "pre-download liferay"

if [ ! -f "/opt/liferay-ce-portal-tomcat-7.0-ga3.zip" ]; then
      echo "Downloading Liferay, this might take a while...";
      wget -nc -nv -P /opt/ "http://downloads.bibbox.org/liferay-ce-portal-tomcat-7.0-ga3.zip";
    else
      echo "Liferay sources already exist. Skipping download.";
fi
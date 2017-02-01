# KIT-EB3KIT
Vagrant, Puppet configuration for the autobuild of the eB3Kit virtual machine


## Requirements

* Download and install Vagrant -> https://www.vagrantup.com
* Download and install VirtualBox -> https://www.virtualbox.org


## Configuration

The following parameters can be adjusted in `environments\production\manisfests\config.pp`:

| Parameter     | Description                                                                                                          | Default                        |
|---------------|----------------------------------------------------------------------------------------------------------------------|--------------------------------|
| bibboxkit     | Name of the BIBBOX kit, currently only eB3kit is available.                                                                                              | eB3Kit                         |
| bibboxbaseurl | Base url of the kit which identifies the virtual machine. Needs to match 'bibboxbaseurl' parameter in 'Vagrantfile'. | eb3kit.bibbox.org              |
| serveradmin   | Mail address of the administrator.                                                                                   | admin@bibbox.org               |
| db_user       | User of the Liferay database.                                                                                        | liferay                        |
| db_password   | Password of the Liferay database.                                                                                    | CHANGEulHbbFpulHbM74JuBk9@CwMS |
| db_name       | Name of the Liferay database.                                                                                        | lportal                        |


## Install Instructions

1. Download or clone this Git repository, **git clone https://github.com/bibbox/kit-eb3kit.git your-vm-name**
2. Open up a terminal and navigate to the repository, **cd your-vm-name**
3. Edit the vagrant configuratio as descibed abobve, **nano Vagrantfile**
4. Edit the puppet configuration as descibed abobve, **nano  environments/production/manifests/config.pp**
5. Execute command in your base directory,  **vagrant up**
6. Wait while your BIBBOX is being installed (can take quite long, depending on internet connection)
7. Configure your proxy or DNS to access the BIBBOX VM at **http://bibboxbaseurl** or use **http://192.168.10.1:1080** (replace 1080 by the port you configured in the Vagrantfile)

## Default login

You can login with the users *admin*, *pi*, *curator* and *operator*.  For all users the default password is *graz2017*. 

The liferay portal can be configured as Liferay administrator, login  *bibboxadmin*, password *graz2017*.  

## Dependencies

The automatic BIBBOX setup is dependend on multiple repositories and one ZIP file download link:

* Liferay ZIP file: http://downloads.bibbox.org/liferay-ce-portal-tomcat-7.0-ga3.zip
* BIBBOX Repository 'sys-bibbox-vmscripts': https://github.com/bibbox/sys-bibbox-vmscripts
* BIBBOX Repository 'application-store': https://github.com/bibbox/application-store
* BIBBOX Repository 'sys-bibbox-frontend': https://github.com/bibbox/sys-bibbox-frontend
* BIBBOX Repository 'sys-bibbox-backend': https://github.com/bibbox/sys-bibbox-backend
* BIBBOX Repository 'sys-activities': https://github.com/bibbox/sys-activities
* BIBBOX Repository 'sys-idmapping': https://github.com/bibbox/sys-idmapping


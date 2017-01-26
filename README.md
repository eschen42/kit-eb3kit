# KIT-EB3KIT
Vagrant, Puppet configuration for the autobuild of the eB3Kit virtual machine


## Requirements

* Download and install Vagrant -> https://www.vagrantup.com
* Download and install VirtualBox -> https://www.virtualbox.org


## Configuration

The following parameters can be adjusted in `environments\production\manisfests\config.pp`:

| Parameter     | Description                                                                                                          | Default                        |
|---------------|----------------------------------------------------------------------------------------------------------------------|--------------------------------|
| bibboxkit     | Name of the BIBBOX kit.                                                                                              | eB3Kit                         |
| bibboxbaseurl | Base url of the kit which identifies the virtual machine. Needs to match 'bibboxbaseurl' parameter in 'Vagrantfile'. | eb3kit.bibbox.org              |
| serveradmin   | Mail address of the administrator.                                                                                   | admin@bibbox.org               |
| db_user       | User of the Liferay database.                                                                                        | liferay                        |
| db_password   | Password of the Liferay database.                                                                                    | CHANGEulHbbFpulHbM74JuBk9@CwMS |
| db_name       | Name of the Liferay database.                                                                                        | lportal                        |


## Install Instructions

1. Download or clone this Git repository
2. Open up a terminal and navigate to the repository
3. Execute command `$ vagrant up`
4. Wait while your BIBBOX is being installed (can take quite long, depending on internet connection)
5. Access your BIBBOX at http://192.168.10.1:18080/


## Dependencies

The automatic BIBBOX setup is dependend on multiple repositories and one ZIP file download link:

* Liferay ZIP file: http://downloads.bibbox.org/liferay-ce-portal-tomcat-7.0-ga3.zip
* BIBBOX Repository 'sys-bibbox-vmscripts': https://github.com/bibbox/sys-bibbox-vmscripts
* BIBBOX Repository 'application-store': https://github.com/bibbox/application-store
* BIBBOX Repository 'sys-bibbox-frontend': https://github.com/bibbox/sys-bibbox-frontend
* BIBBOX Repository 'sys-bibbox-backend': https://github.com/bibbox/sys-bibbox-backend
* BIBBOX Repository 'sys-activities': https://github.com/bibbox/sys-activities
* BIBBOX Repository 'sys-idmapping': https://github.com/bibbox/sys-idmapping


## Inspirations

* https://blog.mimacom.com/liferay-automated-development-and-deployment/
* https://github.com/mimacom/liferay-puppet-deployment
* https://github.com/fafonso/liferay-puppet-vm

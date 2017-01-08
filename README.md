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


## Inspirations

* https://blog.mimacom.com/liferay-automated-development-and-deployment/
* https://github.com/mimacom/liferay-puppet-deployment
* https://github.com/fafonso/liferay-puppet-vm

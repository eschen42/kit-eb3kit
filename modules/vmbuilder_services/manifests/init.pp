class vmbuilder_services (

		$bibboxkit         = "eB3Kit",
		$bibboxbaseurl     = "eb3kit.bibbox.org",
		$serveradmin       = "admin@bibbox.org",

		$db_user           = "liferay",
		$db_password       = "bibbox4ever",
		$db_name           = "lportal"

) {


		# Start bibbox and liferay services
		Service <| title == 'apache2' |> {
				ensure 		=> running,
				enable 		=> true,
				subscribe	=> File['/etc/init.d/bibbox']
		}
		service { 'bibbox':
				ensure 		=> running,
				enable 		=> true,
				subscribe	=> File['/etc/init.d/bibbox']
		}
		service { 'liferay':
				ensure 		=> running,
				enable 		=> true,
				subscribe	=> File['/etc/init.d/liferay']
		}


		# Create and symlink datastore directories
		file { '/var/www/html/bibbox-datastore':
				ensure	=> 'directory'
		}
		file { '/var/www/html/bibbox-datastore/bibbox':
				ensure	=> 'link',
				target	=> '/opt/bibbox/application-store/'
		}
		file { '/var/www/html/bibbox-datastore/js':
				ensure	=> 'directory',
				owner		=> 'root',
				group 	=> 'bibbox',
				mode 		=> '0777'
		}
		file { '/var/www/html/bibbox-datastore/index.html':
				ensure		=> 'file',
				source		=> '/vagrant/resources/index.html'
		}
		file { '/var/www/html/error/index.html':
				ensure		=> 'file',
				source		=> '/vagrant/resources/error/index.html'
		}
		file { '/var/www/html/bibbox-datastore/log.out':
				ensure		=> 'link',
				target		=> '/opt/liferay/tomcat-8.0.32/logs/catalina.out'
		}


		# Copy gui resources to datastore
		file { '/var/www/html/bibbox-datastore/js/js':
				recurse		=> true,
				source		=> '/opt/bibbox/sys-bibbox-frontend/js',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-frontend']
		}
		file { '/var/www/html/bibbox-datastore/js/css':
				recurse		=> true,
				source		=> '/opt/bibbox/sys-bibbox-frontend/css',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-frontend']
		}
		file { '/var/www/html/bibbox-datastore/js/images':
				recurse		=> true,
				source		=> '/opt/bibbox/sys-bibbox-frontend/images',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-frontend']
		}


		# Remove setup config file to reapply configuration on provisioning
		file { '/etc/bibbox/conf.d/setup.cfg':
				ensure	=> 'absent'
		}


		# Install requirements for liferay setup script
		exec { 'pythonRequirements':
				path		=> '/usr/bin',
				command	=> '/usr/bin/pip3 install -r /opt/bibbox/sys-bibbox-vmscripts/setup-liferay/scripts/requirements.txt'
		}


		# Install requirements for liferay setup script
		exec { 'pythonRequirements':
				path		=> '/usr/bin',
				command	=> '/usr/bin/pip3 install -r /opt/bibbox/sys-bibbox-vmscripts/setup-liferay/scripts/requirements.txt'
		}


		# Compose and run the sys-activities container, create docker network and copy script for deleting docker containers
		docker_network { 'bibbox-default-network':
				ensure   	=> present]
		}
		exec { 'dockerUpActivities':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-activities/docker-compose.yml up -d',
				timeout   => 1800
		}
		exec { 'dockerUpIdMapping':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-idmapping/docker-compose.yml up -d',
				timeout   => 1800
		}
		exec { 'dockerUpSyncTechnical':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-bibbox-sync/sync-technical/docker-compose.yml up -d',
				timeout   => 1800
		}

		exec { 'dockerUpSyncDomain':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-bibbox-sync/sync-domain/docker-compose.yml up -d',
				timeout   => 1800,
		}






}

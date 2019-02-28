class vmbuilder(

		$bibboxkit         = "eB3Kit",
		$bibboxbaseurl     = "eb3kit.bibbox.org",
		$serveradmin       = "admin@bibbox.org",

		$db_user           = "liferay",
		$db_password       = "bibbox4ever",
		$db_name           = "lportal"

) {

		# Ensure groups 'bibbox' and 'docker'
		group { 'bibbox':
				ensure	=> 'present',
				gid			=> 501
		}
		group { 'docker':
				ensure	=> 'present',
				gid			=> 502
		}
		group { 'liferay':
				ensure	=> 'present',
				gid			=> 503
		}


		# Create users 'bibbox', 'liferay' and 'vmadmin' and update 'root'
		user { 'bibbox':
				ensure		=> 'present',
				gid				=> '501',
				groups		=> ['bibbox', 'docker'],
				uid		    => '501'
		}
		user { 'liferay':
				ensure		=> 'present',
				groups		=> ['bibbox', 'liferay', 'docker'],
				uid		    => '502'
		}
		user { 'root':
				ensure 		=> 'present',
				groups 		=> ['bibbox', 'liferay', 'docker']
		}
		user { 'vmadmin':
				ensure 			=> 'present',
				groups 			=> ['sudo', 'docker'],
				password 		=> '$6$mEf4vngN$erw.SnwvN1g77a/i2FdcGKveS7ktRvvauJHfH/XzHR9eMERn8p5sJzF7GTUoypvVU37u6IPaUeTvC9UZj8zOL1',
				managehome	=> true,
				home 				=> '/home/vmadmin',
				uid 				=> '507'
		}


		# Install apache with default config
		class { 'apache':
				default_vhost     => false,
				purge_vhost_dir   => false
		}
		class { 'apache::mod::proxy': }
		class { 'apache::mod::proxy_http': }
		class { 'apache::mod::proxy_ajp': }
		class { 'apache::mod::proxy_wstunnel': }


		# Define default vhost, or apache can't start
		apache::vhost { $bibboxbaseurl:
				port    	=> ['80','85'],
				docroot 	=> '/var/www/vhost'
		}


		# Install oracle java
		class { 'jdk_oracle':
				jce							=> true,
				default_java		=> true,
				version					=> '8',
				version_update 	=> '131',
				version_build		=> '13',
				version_hash		=> '75b2cb2249710d822a60f83e28860053',
				download_url		=> 'http://downloads.bibbox.org/java',
				before => Archive['/opt/liferay-ce-portal-tomcat-7.0-ga3.zip']
		}


		# Install and configure postgresql
		class { 'postgresql::server': }
		postgresql::server::role { $db_user:
				password_hash 	=> postgresql_password($db_user, $db_password),
		}
		postgresql::server::db { $db_name:
				user     		=> $db_user,
				password 		=> postgresql_password($db_user, $db_password)
		}
		postgresql::server::database_grant { $db_name:
				privilege 	=> 'ALL',
				db        	=> $db_name,
				role      	=> $db_user
		}


		# Unzip liferay sources to 'liferay' directory
		archive { '/opt/liferay-ce-portal-tomcat-7.0-ga3.zip':
				ensure 				=> 'present',
				extract       => true,
				extract_path	=> '/opt',
				creates       => '/opt/liferay-ce-portal-7.0-ga3',
				cleanup       => true,
				notify				=> File['MoveLiferayContents']
		}


		# Delete temporary zip file
		# file { '/opt/liferay.zip':
		# 		ensure 		=> 'absent',
		# 		subscribe	=> Archive['/opt/liferay-ce-portal-tomcat-7.0-ga3.zip']
		# }


		# Copy unzipped liferay contents and delete source
		file { "MoveLiferayContents":
				ensure 		=> 'directory',
				path 			=> '/opt/liferay',
				source 		=> '/opt/liferay-ce-portal-7.0-ga3',
				recurse 	=> true,
				owner			=> 'liferay',
				group   	=> 'liferay',
				subscribe => Archive['/opt/liferay-ce-portal-tomcat-7.0-ga3.zip']
		}
		file { '/opt/liferay/deploy':
				ensure 		=> 'directory',
				mode 			=> '0777',
				owner 		=> 'liferay',
				group 		=> 'liferay',
				subscribe	=> File['MoveLiferayContents']
		}
		file { '/opt/liferay/tomcat-8.0.32/bin':
				ensure 		=> 'present',
				source 		=> '/opt/liferay-ce-portal-7.0-ga3/tomcat-8.0.32/bin',
				recurse		=> true,
				mode 			=> '0777',
				owner 		=> 'liferay',
				group 		=> 'liferay',
				subscribe	=> File['MoveLiferayContents']
		}
		file { '/opt/liferay-ce-portal-7.0-ga3':
				ensure 		=> 'absent',
				purge 		=> true,
				recurse 	=> true,
				force 		=> true,
				subscribe	=> File['/opt/liferay/tomcat-8.0.32/bin']
		}


		# Copy 'war' files to liferay deploy folder
		file { "/opt/liferay/deploy/BIBBOXDocker-portlet-7.0.0.1.war":
				ensure 		=> 'file',
				owner			=> 'liferay',
				group   	=> 'liferay',
				mode 			=> '0777',
				source 		=> '/vagrant/resources/BIBBOXDocker-portlet-7.0.0.1.war',
				subscribe	=> File['MoveLiferayContents']
		}
		file { "/opt/liferay/deploy/bibbox-theme.war":
				ensure 		=> 'file',
				owner			=> 'liferay',
				group   	=> 'liferay',
				mode 			=> '0777',
				source 		=> '/vagrant/resources/bibbox-theme.war',
				subscribe	=> File['MoveLiferayContents']
		}


		# Create directories used by bibbox
		file { '/opt/bibbox':
				ensure 	=> 'directory',
				mode 		=> '0777'
		}
		file { '/opt/bibbox/application-instance':
				ensure	=> 'directory',
				owner		=> 'liferay',
				group   => 'bibbox'
		}
		file { '/opt/bibbox/application-store':
				ensure	=> 'directory',
				owner		=> 'liferay',
				group   => 'bibbox'
		}
		file { '/opt/bibbox/application-import-export':
				ensure	=> 'directory',
				owner		=> 'root',
				group   => 'bibbox'
		}
		file { ['/opt/bibbox/sys-bibbox-sync',
            '/opt/bibbox/sys-bibbox-sync/data',
            '/opt/bibbox/sys-bibbox-sync/data/sync-biobank',
            '/opt/bibbox/sys-bibbox-sync/data/sync-biobank/bibbox',
            '/opt/bibbox/sys-bibbox-sync/data/sync-biobank/bibbox/general-domain']:
				ensure 	=> 'directory',
				mode 		=> '0777'
		}
		file { '/opt/bibbox/sys-bibbox-sync/data/sync-biobank/bibbox/general-machine':
				ensure 	=> 'directory',
				mode 		=> '0777'
		}
		file { ['/opt/bibbox/sys-bibbox-sync/data/sync',
            '/opt/bibbox/sys-bibbox-sync/data/sync/bibbox',
            '/opt/bibbox/sys-bibbox-sync/data/sync/bibbox/general']:
				ensure 	=> 'directory',
				mode 		=> '0777'
		}
		file { '/var/www/html/error':
				ensure	=> 'directory',
				owner		=> 'root',
				group   => 'root',
				mode		=> '0644'
		}


		# Set access rights for apache directories
		File <| title == '/etc/apache2/sites-available' |> {
				owner	=> 'root',
				group   => 'bibbox',
				mode 	=> '0777'
		}
		File <| title == '/etc/apache2/sites-enabled' |> {
				owner	=> 'root',
				group   => 'bibbox',
				mode 	=> '0777'
		}


		# Clone bibbox repositories
		vcsrepo { '/opt/bibbox/sys-bibbox-vmscripts':
				ensure   	=> 'latest',
				provider 	=> 'git',
				source   	=> 'https://github.com/bibbox/sys-bibbox-vmscripts.git',
				subscribe => File['/opt/liferay/tomcat-8.0.32/bin'],
				notify		=> Exec['pythonRequirements']
		}
		vcsrepo { '/opt/bibbox/application-store/application-store':
				ensure   	=> 'latest',
				provider	=> 'git',
				owner			=> 'liferay',
				group   	=> 'bibbox',
				source  	=> 'https://github.com/bibbox/application-store.git',
				notify		=> File['/var/www/html/bibbox-datastore/index.html']
		}
		vcsrepo { '/opt/bibbox/sys-bibbox-frontend':
				ensure  	=> 'latest',
				provider 	=> 'git',
				source   	=> 'https://github.com/bibbox/sys-bibbox-frontend.git'
		}
		vcsrepo { '/opt/bibbox/sys-activities':
				ensure   	=> 'latest',
				provider 	=> 'git',
				source   	=> 'https://github.com/bibbox/sys-activities.git'
		}
		vcsrepo { '/opt/bibbox/sys-idmapping':
				ensure   	=> 'latest',
				provider 	=> 'git',
				source   	=> 'https://github.com/bibbox/sys-idmapping.git'
		}
		vcsrepo { '/opt/bibbox/sys-bibbox-sync/sync-technical':
				ensure   	=> 'latest',
				provider 	=> 'git',
				source   	=> 'https://github.com/bibbox/sys-bibbox-sync.git'
		}
		vcsrepo { '/opt/bibbox/sys-bibbox-sync/sync-domain':
				ensure   	=> 'latest',
				provider 	=> 'git',
				source   	=> 'https://github.com/bibbox/sys-bibbox-sync.git'
		}


		# Copy bibbox configuration and init scripts
		file { "/etc/init.d/bibbox":
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/init.d/bibbox',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-vmscripts']
		}
		file { "/etc/init.d/functions":
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/init.d/functions',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-vmscripts']
		}
		file { "/etc/init.d/liferay":
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/init.d/liferay',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-vmscripts']
		}
		file { "/opt/liferay/portal-ext.properties":
				owner  		=> 'liferay',
				group  		=> 'liferay',
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/liferay/portal-ext.properties',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-vmscripts']
		}
		file { "/opt/liferay/portal-setup-wizard.properties":
				ensure  	=> 'file',
				owner  		=> 'liferay',
				group  		=> 'liferay',
				content 	=> epp('/vagrant/resources/templates/portal-setup-wizard.properties.epp', {
						'db_user'			=> $db_user,
						'db_password'	=> $db_password,
						'db_name'			=> $db_name
				}),
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-vmscripts']
		}
		file { "/etc/bibbox":
				recurse 	=> true,
				owner  		=> 'root',
				group  		=> 'bibbox',
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/bibbox',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-vmscripts']
		}
		file { "/opt/bibbox/metadata":
				recurse 	=> true,
				owner  		=> 'root',
				group  		=> 'root',
				mode			=> '0777',
				source 		=> '/opt/bibbox/application-store/application-store/metadata',
				subscribe	=> Vcsrepo['/opt/bibbox/application-store/application-store']
		}
		file { "/opt/bibbox/sys-bibbox-sync/sync-technical/docker-compose.yml":
				ensure  	=> 'file',
				source 		=> '/vagrant/resources/docker-compose-technical.yml',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-sync/sync-technical']
		}
		file { "/opt/bibbox/sys-bibbox-sync/sync-domain/docker-compose.yml":
				ensure  	=> 'file',
				source 		=> '/vagrant/resources/docker-compose-domain.yml',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-sync/sync-domain']
		}


		# Create 'conf.d' directory
		file { '/etc/bibbox/conf.d':
				ensure		=> 'directory',
				owner  		=> 'root',
				group  		=> 'bibbox'
		}


		# Render 'bibbox.cfg' template file
		file { "/etc/bibbox/bibbox.cfg":
				ensure  	=> 'file',
				owner  		=> 'root',
				group  		=> 'bibbox',
				content 	=> epp('/vagrant/resources/templates/bibbox.cfg.epp', {
						'bibboxkit'			=> $bibboxkit,
						'bibboxbaseurl'	=> $bibboxbaseurl
				})
		}


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

        exec { 'installLiferayContent':
				path	  => '/usr/bin',
				command   => '/usr/bin/sudo  /opt/bibbox/sys-bibbox-vmscripts/initscripts/runSetupScript.sh',
                subscribe	=> Service['liferay'],
				timeout   => 2800
		}

		# Install docker and docker compose
		include 'docker'
		class { 'docker::compose':
				version => '1.8.1'
		}


		# Compose and run the sys-activities container, create docker network and copy script for deleting docker containers
		docker_network { 'bibbox-default-network':
				ensure   	=> present,
				subscribe	=> Vcsrepo['/opt/bibbox/sys-activities']
		}
		exec { 'dockerUpActivities':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-activities/docker-compose.yml up -d',
				timeout   => 1800,
				subscribe	=> Docker_network['bibbox-default-network'],
				require 	=> Class['docker::compose']
		}
		exec { 'dockerUpIdMapping':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-idmapping/docker-compose.yml up -d',
				timeout   => 1800,
				subscribe	=> Docker_network['bibbox-default-network'],
				require 	=> Class['docker::compose']
		}
		exec { 'dockerUpSyncTechnical':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-bibbox-sync/sync-technical/docker-compose.yml up -d',
				timeout   => 1800,
				subscribe	=> Docker_network['bibbox-default-network'],
				require 	=> Class['docker::compose']
		}
		exec { 'dockerUpSyncDomain':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-bibbox-sync/sync-domain/docker-compose.yml up -d',
				timeout   => 1800,
				subscribe	=> Docker_network['bibbox-default-network'],
				require 	=> Class['docker::compose']
		}
		file { "/etc/bibbox/delete_root_folder_applications.sh":
				ensure		=> 'file',
				owner  		=> 'root',
				group  		=> 'root',
				mode			=> '0744',
				source 		=> '/vagrant/resources/delete_root_folder_applications.sh'
		}
		file { "/etc/sudoers.d/liferaydeletescript":
				ensure  	=> 'file',
				owner  		=> 'root',
				group  		=> 'root',
				mode			=> '0440',
				source 		=> '/vagrant/resources/liferaydeletescript'
		}


		# Configure vhosts for apache
		file { "/etc/apache2/sites-available/000-default.conf":
				ensure  => 'file',
				content => epp('/vagrant/resources/templates/000-default.conf.epp', {
						'bibboxbaseurl'	=> $bibboxbaseurl
				})
		}
		file { "/etc/apache2/sites-available/001-default-application-store.conf":
				ensure  => 'file',
				content => epp('/vagrant/resources/templates/001-default-application-store.conf.epp', {
						'serveradmin'	=> $serveradmin,
						'bibboxbaseurl'	=> $bibboxbaseurl
				})
		}
		file { "/etc/apache2/sites-available/050-liferay.conf":
				ensure  => 'file',
				content => epp('/vagrant/resources/templates/050-liferay.conf.epp', {
						'bibboxbaseurl'	=> $bibboxbaseurl
				})
		}
  
        
		# Symlink the new vhosts config files
		file { '/etc/apache2/sites-enabled/001-default-application-store.conf':
				ensure		=> 'link',
				target		=> '/etc/apache2/sites-available/001-default-application-store.conf',
				subscribe => File['/etc/apache2/sites-available/001-default-application-store.conf']
		}
		file { '/etc/apache2/sites-enabled/050-liferay.conf':
				ensure		=> 'link',
				target		=> '/etc/apache2/sites-available/050-liferay.conf',
				subscribe => File['/etc/apache2/sites-available/050-liferay.conf']
		}


		# Copy 'urlrewrite.xml' to tomcat
		file { "/opt/liferay/tomcat-8.0.32/webapps/ROOT/WEB-INF/urlrewrite.xml":
				ensure 	=> 'file',
				source 	=> '/vagrant/resources/urlrewrite.xml'
		}

}

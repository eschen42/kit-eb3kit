class vmbuilder_files(
		$bibboxkit         = "eB3Kit",
		$bibboxbaseurl     = "eb3kit.bibbox.org",
		$serveradmin       = "admin@bibbox.org",
  	$db_user           = "liferay",
		$db_password       = "vendetta",
		$db_name           = "lportal"
) {



    #######################
    #      LIFERAY  BASE  #
    #######################
		archive { '/opt/liferay-ce-portal-tomcat-7.0-ga3.zip':
				ensure 				=> 'present',
				extract       => true,
				extract_path	=> '/opt',
				creates       => '/opt/liferay-ce-portal-7.0-ga3',
				cleanup       => true,
				notify				=> File['MoveLiferayContents']
		}

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

    #######################
    #       BIBBOX        #
    #######################
		file { "/opt/liferay/deploy/BIBBOXDocker-portlet-7.0.0.1.war":
				ensure 		=> 'file',
				owner			=> 'liferay',
				group   	=> 'liferay',
				mode 			=> '0777',
				source 		=> '/opt/bibbox-install/resources/BIBBOXDocker-portlet-7.0.0.1.war',
				subscribe	=> File['MoveLiferayContents']
		}
		file { "/opt/liferay/deploy/bibbox-theme.war":
				ensure 		=> 'file',
				owner			=> 'liferay',
				group   	=> 'liferay',
				mode 			=> '0777',
				source 		=> '/opt/bibbox-install/resources/bibbox-theme.war',
				subscribe	=> File['MoveLiferayContents']
		}


	  #######################
    #       DIRECTORIES   #
    #######################
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


  	#######################
    #        APACHE       #
    #######################
		file { '/var/www/html/error':
				ensure	=> 'directory',
				owner		=> 'root',
				group   => 'root',
				mode		=> '0644'
		}

  	#######################
    #  CLONE FROM GIT     #
    #######################
		vcsrepo { '/opt/bibbox/sys-bibbox-vmscripts':
				ensure   	=> 'latest',
				provider 	=> 'git',
				source   	=> 'https://github.com/bibbox/sys-bibbox-vmscripts.git'
		}

		exec { 'changePermissionOfVMScrips':
				path			=> '/bin',
				command 	=> '/usr/bin/sudo chmod +x /opt/bibbox/sys-bibbox-vmscripts/*.sh',
				timeout   => 1800
		}

		vcsrepo { '/opt/bibbox/application-store/application-store':
				ensure   	=> 'latest',
				provider	=> 'git',
				owner			=> 'liferay',
				group   	=> 'bibbox',
				source  	=> 'https://github.com/bibbox/application-store.git'
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


  	#######################
    #      COPY FILES     #
    #######################


		# Copy bibbox configuration and init scripts
		file { "/etc/init.d/bibbox":
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/init.d/bibbox',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777'
		}
		file { "/etc/init.d/functions":
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/init.d/functions',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777'
		}
		file { "/etc/init.d/liferay":
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/init.d/liferay',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777'
		}
		file { "/opt/liferay/portal-ext.properties":
				owner  		=> 'liferay',
				group  		=> 'liferay',
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/liferay/portal-ext.properties'
		}

		file { "/opt/liferay/portal-setup-wizard.properties":
				ensure  	=> 'file',
				owner  		=> 'liferay',
				group  		=> 'liferay',
				content 	=> epp('/opt/bibbox-install/resources/templates/portal-setup-wizard.properties.epp', {
						'db_user'			=> $db_user,
						'db_password'	=> $db_password,
						'db_name'			=> $db_name
				})
		}
		file { "/etc/bibbox":
				recurse 	=> true,
				owner  		=> 'root',
				group  		=> 'bibbox',
				source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/bibbox'
		}
		file { "/opt/bibbox/metadata":
				recurse 	=> true,
				owner  		=> 'root',
				group  		=> 'root',
				mode			=> '0777',
				source 		=> '/opt/bibbox/application-store/application-store/metadata'
		}

	  #########################################
    #  SYNC (is this copied twice ?         #
    #########################################
		file { "/opt/bibbox/sys-bibbox-sync/sync-technical/docker-compose.yml":
				ensure  	=> 'file',
				source 		=> '/opt/bibbox-install/resources/docker-compose-technical.yml',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777'
		}
		file { "/opt/bibbox/sys-bibbox-sync/sync-domain/docker-compose.yml":
				ensure  	=> 'file',
				source 		=> '/opt/bibbox-install/resources/docker-compose-domain.yml',
				owner  		=> 'root',
				group  		=> 'root',
				mode   		=> '0777',
				subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-sync/sync-domain']
		}


    #########################################
    #  CONFIGURE BIBBOX SERVICE             #
    #########################################

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
				content 	=> epp('/opt/bibbox-install/resources/templates/bibbox.cfg.epp', {
						'bibboxkit'			=> $bibboxkit,
						'bibboxbaseurl'	=> $bibboxbaseurl
				})
		}

    #########################################
    #        CONFIGURE DATASTORE            #
    #########################################
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
				source		=> '/opt/bibbox-install/resources/index.html'
		}
		file { '/var/www/html/error/index.html':
				ensure		=> 'file',
				source		=> '/opt/bibbox-install/resources/error/index.html'
		}
		file { '/var/www/html/bibbox-datastore/log.out':
				ensure		=> 'link',
				target		=> '/opt/liferay/tomcat-8.0.32/logs/catalina.out'
		}


    #########################################
    #       COPY GUI FILES TO DATASTORE     #
    #########################################
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


    #########################################
    #              COPY SCRIPTS             #
    #########################################
		file { "/etc/bibbox/delete_root_folder_applications.sh":
				ensure		=> 'file',
				owner  		=> 'root',
				group  		=> 'root',
				mode			=> '0744',
				source 		=> '/opt/bibbox-install/resources/delete_root_folder_applications.sh'
		}

		file { "/etc/sudoers.d/liferaydeletescript":
				ensure  	=> 'file',
				owner  		=> 'root',
				group  		=> 'root',
				mode			=> '0440',
				source 		=> '/opt/bibbox-install/resources/liferaydeletescript'
		}

    #########################################
    #  COPY APACHE FILE AND CONFIGURE FQSN  #
	  #########################################
	  	file { "/etc/apache2/conf.d/localdatastoreport.conf":
				ensure 	=> 'file',
				source 	=> '/opt/bibbox-install/resources/localdatastoreport.conf'
		}
		file { "/etc/apache2/sites-available/000-default.conf":
				ensure  => 'file',
				content => epp('/opt/bibbox-install/resources/templates/000-default.conf.epp', {
						'bibboxbaseurl'	=> $bibboxbaseurl
				})
		}
		file { "/etc/apache2/sites-available/001-default-application-store.conf":
				ensure  => 'file',
				content => epp('/opt/bibbox-install/resources/templates/001-default-application-store.conf.epp', {
						'serveradmin'	=> $serveradmin,
						'bibboxbaseurl'	=> $bibboxbaseurl
				})
		}
		file { "/etc/apache2/sites-available/050-liferay.conf":
				ensure  => 'file',
				content => epp('/opt/bibbox-install/resources/templates/050-liferay.conf.epp', {
						'bibboxbaseurl'	=> $bibboxbaseurl
				})
		}

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


    #########################################
    #  COPY URL REWRITE                     #
	  #########################################
	  file { "/opt/liferay/tomcat-8.0.32/webapps/ROOT/WEB-INF/urlrewrite.xml":
				ensure 	=> 'file',
				source 	=> '/opt/bibbox-install/resources/urlrewrite.xml'
		}

		# Remove setup config file to reapply configuration on provisioning
		file { '/etc/bibbox/conf.d/setup.cfg':
				ensure	=> 'absent'
		}
}

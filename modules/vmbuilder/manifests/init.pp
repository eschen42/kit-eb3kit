class vmbuilder(

	$bibboxkit			= "buildKit",
	$bibboxbaseurl		= "build.bibbox.org",
	$serveradmin		= "admin@bibbox.org",

	$db_user            = "liferay",
	$db_password        = "CHANGEulHbbFpulHbM74JuBk9@CwMS",
	$db_name            = "lportal"

) {

	# Ensure groups 'bibbox' and 'docker'
	group { 'bibbox':
		ensure	=> 'present',
		gid		=> 501
	}
	group { 'docker':
		ensure	=> 'present',
		gid		=> 502
	}
	group { 'liferay':
		ensure	=> 'present',
		gid		=> 503
	}


	# Ensure users 'bibbox' ans 'liferay'
	user { 'bibbox':
		ensure           	=> 'present',
		gid              	=> '501',
		home             	=> '/home/bibbox',
		groups				=> ['bibbox', 'docker'],
		uid              	=> '501'
	}
	user { 'liferay':
		ensure           	=> 'present',
		home             	=> '/home/liferay',
		groups				=> ['bibbox', 'liferay', 'docker'],
		uid              	=> '502'
	}
	user { 'root':
		ensure 	=> 'present',
		groups 	=> ['bibbox', 'liferay', 'docker']
	}


	# Install apache with default config
	class { 'apache': }
	class { 'apache::mod::proxy': }
	class { 'apache::mod::proxy_http': }
	class { 'apache::mod::proxy_ajp': }
	class { 'apache::mod::proxy_wstunnel': }


	# Install oracle java
	class { 'jdk_oracle':
	  	jce => true
	}


	# Install and configure postgresql
	class { 'postgresql::server': }
	postgresql::server::role { $db_user:
		password_hash 	=> postgresql_password($db_user, $db_password),
	}
	postgresql::server::db { $db_name:
		user     	=> $db_user,
		password 	=> postgresql_password($db_user, $db_password)
	}
	postgresql::server::database_grant { $db_name:
		privilege 	=> 'ALL',
		db        	=> $db_name,
		role      	=> $db_user
	}


	# Unzip liferay sources to 'liferay' directory
	archive { '/tmp/liferay-ce-portal-tomcat-7.0-ga3.zip':
		ensure 			=> 'present',
		extract       	=> true,
		extract_path  	=> '/opt',
		creates       	=> '/opt/liferay-ce-portal-7.0-ga3',
		cleanup       	=> true,
		notify			=> File['MoveLiferayContents']
	}


	# Delete temporary zip file
	# file { '/tmp/liferay.zip':
	# 	ensure 		=> 'absent',
	# 	subscribe	=> Archive['/tmp/liferay-ce-portal-tomcat-7.0-ga3.zip']
	# }


	# Copy unzipped liferay contents and delete source
	file { "MoveLiferayContents":
		ensure 		=> 'directory',
	   	path 		=> '/opt/liferay',
		source 		=> '/opt/liferay-ce-portal-7.0-ga3',
		recurse 	=> true,
	    owner		=> 'liferay',
	    group   	=> 'liferay',
	    subscribe 	=> Archive['/tmp/liferay-ce-portal-tomcat-7.0-ga3.zip']
	}
	file { '/opt/liferay/tomcat-8.0.32/bin':
		ensure 		=> 'present',
		source 		=> '/opt/liferay-ce-portal-7.0-ga3/tomcat-8.0.32/bin',
		recurse		=> true,
		mode 		=> '0777',
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
	    owner		=> 'liferay',
	    group   	=> 'liferay',
	    mode 		=> '0777',
	    source 		=> '/vagrant/resources/BIBBOXDocker-portlet-7.0.0.1.war',
		subscribe	=> File['MoveLiferayContents']
	}
	file { "/opt/liferay/deploy/bibbox-theme.war":
		ensure 		=> 'file',
	    owner		=> 'liferay',
	    group   	=> 'liferay',
	    mode 		=> '0777',
	    source 		=> '/vagrant/resources/bibbox-theme.war',
		subscribe	=> File['MoveLiferayContents']
	}


	# Create directories used by bibbox
	file { '/opt/bibbox':
		ensure 	=> 'directory',
		mode 	=> '0777'
	}
	file { '/opt/bibbox/application-instance':
		ensure	=> 'directory',
	    owner	=> 'liferay',
	    group   => 'bibbox'
	}
	file { '/opt/bibbox/application-store':
		ensure	=> 'directory',
	    owner	=> 'liferay',
	    group   => 'bibbox'
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
	  ensure   		=> 'present',
	  provider 		=> 'git',
	  source   		=> 'https://github.com/bibbox/sys-bibbox-vmscripts.git',
	  subscribe 	=> File['/opt/liferay/tomcat-8.0.32/bin']
	}
	vcsrepo { '/opt/bibbox/application-store':
	  ensure   => 'present',
	  provider => 'git',
	  source   => 'https://github.com/bibbox/application-store.git'
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
			'db_password'	=> $db_password
		}),
		subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-vmscripts']
	}
	file { "/etc/bibbox":
	   	recurse 	=> true,
	    source 		=> '/opt/bibbox/sys-bibbox-vmscripts/initscripts/etc/bibbox',
		subscribe	=> Vcsrepo['/opt/bibbox/sys-bibbox-vmscripts']
	}


	# Create 'conf.d' directory
	file { '/etc/bibbox/conf.d':
		ensure	=> 'directory'
	}


	# Render 'bibbox.cfg' template file
	file { "/etc/bibbox/bibbox.cfg":
		ensure  => 'file',
		content => epp('/vagrant/resources/templates/bibbox.cfg.epp', {
			'bibboxkit'		=> $bibboxkit,
			'bibboxbaseurl'	=> $bibboxbaseurl
		})
	}


	# Start bibbox and liferay services
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
	    owner	=> 'root',
	    group 	=> 'bibbox',
	    mode 	=> '0777'
	}


	# Install docker and docker engine
	include 'docker'


	# Configure vhosts for apache
	file { "/etc/apache2/sites-available/001-default-application-store.conf":
		ensure  => 'file',
		content => epp('/vagrant/resources/templates/001-default-application-store.conf.epp', {
			'serveradmin'	=> $serveradmin,
			'bibboxbaseurl'	=> $bibboxbaseurl
		})
	}
	file { "/etc/apache2/sites-available/003-sys-activities.conf":
		ensure  => 'file',
		content => epp('/vagrant/resources/templates/003-sys-activities.conf.epp', {
			'bibboxbaseurl'	=> $bibboxbaseurl
		})
	}
	file { "/etc/apache2/sites-available/003-sys-idmapping.conf":
		ensure  => 'file',
		content => epp('/vagrant/resources/templates/003-sys-idmapping.conf.epp', {
			'bibboxbaseurl'	=> $bibboxbaseurl
		})
	}
	file { "/etc/apache2/sites-available/050-liferay.conf":
		ensure  => 'file',
		content => epp('/vagrant/resources/templates/050-liferay.conf.epp', {
			'bibboxbaseurl'	=> $bibboxbaseurl
		})
	}
	file { '/etc/apache2/sites-enabled/000-default.conf':
		ensure 	=> 'absent'
	}


	# Symlink the new vhosts config files
	file { '/etc/apache2/sites-enabled/001-default-application-store.conf':
		ensure		=> 'link',
	    target		=> '/etc/apache2/sites-available/001-default-application-store.conf',
	    subscribe 	=> File['/etc/apache2/sites-available/001-default-application-store.conf']
	}
	file { '/etc/apache2/sites-enabled/003-sys-activities.conf':
		ensure		=> 'link',
	    target		=> '/etc/apache2/sites-available/003-sys-activities.conf',
	    subscribe 	=> File['/etc/apache2/sites-available/003-sys-activities.conf']
	}
	file { '/etc/apache2/sites-enabled/003-sys-idmapping.conf':
		ensure		=> 'link',
	    target		=> '/etc/apache2/sites-available/003-sys-idmapping.conf',
	    subscribe 	=> File['/etc/apache2/sites-available/003-sys-idmapping.conf']
	}
	file { '/etc/apache2/sites-enabled/050-liferay.conf':
		ensure		=> 'link',
	    target		=> '/etc/apache2/sites-available/050-liferay.conf',
	    subscribe 	=> File['/etc/apache2/sites-available/050-liferay.conf']
	}


	# Copy 'urlrewrite.xml' to tomcat
	file { "/opt/liferay/tomcat-8.0.32/webapps/ROOT/WEB-INF/urlrewrite.xml":
	   	ensure 	=> 'file',
	    source 	=> '/vagrant/resources/urlrewrite.xml'
	}

}
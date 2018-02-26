class vmbuilder_services (

		$bibboxkit         = "eB3Kit",
		$bibboxbaseurl     = "eb3kit.bibbox.org",
		$serveradmin       = "admin@bibbox.org",

		$db_user           = "liferay",
		$db_password       = "bibbox4ever",
		$db_name           = "lportal"

) {

    #########################################
    #        LIFERAY SETUP SCRIPT           #
    #########################################
		exec { 'pythonRequirements':
				path		=> '/usr/bin',
				command	=> '/usr/bin/pip3 install -r /opt/bibbox/sys-bibbox-vmscripts/setup-liferay/scripts/requirements.txt'
		}


    #########################################
    #           BIBBOX / LIFERAY            #
    #########################################
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


    #########################################
    #        DOCKER SERVICES                #
    #########################################

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

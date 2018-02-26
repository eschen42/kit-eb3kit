class vmbuilder_services (
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
				enable 		=> true
		}
		service { 'liferay':
				ensure 		=> running,
				enable 		=> true
		}

		service { 'bibbox':
				ensure 		=> running,
				enable 		=> true
		}


    #########################################
    #        DOCKER SERVICES                #
    #########################################

		docker_network { 'bibbox-default-network':
				ensure   	=> present
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

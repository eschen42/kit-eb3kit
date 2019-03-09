class vmbuilder_services (
) {


    #########################################
    #           BIBBOX / LIFERAY            #
    #########################################
		Service <| title == 'apache2' |> {
				ensure 		=> running,
				enable 		=> true
		}

    exec { 'reloadApache':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo service apache2 restart',
				timeout   => 1800
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
    #        LIFERAY SETUP SCRIPT           #
    #########################################
		exec { 'pythonRequirements':
				path		=> '/usr/bin',
				command	=> '/usr/bin/pip3 install -r /opt/bibbox/sys-bibbox-vmscripts/setup-liferay/scripts/requirements.txt'
		}

    exec { 'installLiferayContent':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo bash /opt/bibbox/sys-bibbox-vmscripts/initscripts/runSetupScript.sh',
				timeout   => 2800
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
				timeout   => 2800
		}
		exec { 'dockerUpIdMapping':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-idmapping/docker-compose.yml up -d',
				timeout   => 2800
		}
		exec { 'dockerUpSyncTechnical':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-bibbox-sync/sync-technical/docker-compose.yml up -d',
				timeout   => 2800
		}
		exec { 'dockerUpSyncDomain':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo /usr/local/bin/docker-compose -f /opt/bibbox/sys-bibbox-sync/sync-domain/docker-compose.yml up -d',
				timeout   => 2800,
		}

}

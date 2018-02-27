class vmbuilder_services (
) {

    #########################################
    #        LIFERAY SETUP SCRIPT           #
    #########################################
		exec { 'pythonRequirements':
				path		=> '/usr/bin',
				command	=> '/usr/bin/pip3 install -r /opt/bibbox/sys-bibbox-vmscripts/setup-liferay/scripts/requirements.txt'
		}

    #
    #  bitte hier das setup /opt/bibbox/sys-bibbox-vmscripts/initscripts/runSetupScript.sh >> /var/log/liferaySetup.log
	  exec { 'dockerUpActivities':
				path			=> '/usr/bin',
				command 	=> '/usr/bin/sudo  /opt/bibbox/sys-bibbox-vmscripts/initscripts/runSetupScript.sh >> /var/log/liferaySetup.log',
				timeout   => 1800
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


    #
    # return code des service checken, setup liferay entfernen
    # IM UPDATE REPOSITORY das PULL auf dei SCRIPTS entfernen
    #

    #
    # zwei scripts machen
    #   a) update auf einen Version
    #   b) wechsel der DOMAIN


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

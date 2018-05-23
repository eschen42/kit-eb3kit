class vmbuilder_ubuntu(
		$bibboxbaseurl     = "eb3kit.bibbox.org",
        ) 
{

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

		# Create users 'bibbox', 'liferay' and update 'root' and 'v'
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
		user { 'v':
				ensure 		=> 'present',
				groups 		=> ['bibbox', 'liferay', 'docker']
		}
}

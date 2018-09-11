class vmbuilder_packages (
  $bibboxbaseurl = "eb3kit.bibbox.org",
  $db_user       = "liferay",
  $db_password   = "bibbox4ever",
  $db_name       = "lportal"
)
  {

    ###################
    #      APACHE     #
    ###################
    class { 'apache':
      default_vhost   => false,
      purge_vhost_dir => false
    }

    class { 'apache::mod::proxy': }
    class { 'apache::mod::proxy_http': }
    class { 'apache::mod::proxy_ajp': }
    class { 'apache::mod::proxy_wstunnel': }

    apache::vhost { $bibboxbaseurl:
      port    => '80',
      docroot => '/var/www/vhost'
     }

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

    ###################
    #      JDK        #
    ###################
    class { 'jdk_oracle':
      jce            => true,
      default_java   => true,
      version        => '8',
      version_update => '131',
      version_build  => '13',
      version_hash   => '75b2cb2249710d822a60f83e28860053',
      download_url   => 'http://downloads.bibbox.org/java',
    }

    ###################
    #     POSTGRES    #
    ###################
    class { 'postgresql::server': }

    postgresql::server::role {
      $db_user:
        password_hash => postgresql_password($db_user, $db_password),
    }

    postgresql::server::db {
      $db_name:
        user     => $db_user,
        password => postgresql_password($db_user, $db_password)
    }


    postgresql::server::database_grant {
      $db_name:
        privilege => 'ALL',
        db        => $db_name,
        role      => $db_user
    }

    ###################
    #     DOCKER      #
    ###################

    include 'docker'
    class { 'docker::compose':
      version => '1.8.1'
    }

  }

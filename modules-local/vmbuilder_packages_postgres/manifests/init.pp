class vmbuilder_packages_postgres (
  $bibboxbaseurl = "eb3kit.bibbox.org",
  $db_user       = "liferay",
  $db_password   = "bibbox4ever",
  $db_name       = "lportal"
)
  {
    ###################
    #     POSTGRES    #
    ###################
    # class { 'postgresql::globals':
    #   datadir              => '/opt/postgres_data',
    # }->
    # class { 'postgresql::server':
    #   needs_initdb => 'true',
    # }
    class { 'postgresql::server': }
    class running_postgresql_service {
      service { 'postgresql':
        ensure => 'running',
        enable => true,
      }
      # restart postgresql serviceon changeto pg_hba.conf
      file { postgresql::params::pg_hba_conf_path:
        notify  => Service['postgresql'],
      }
      # restart postgresql serviceon changeto postgresql.conf
      file { postgresql::params::postgresql_conf_path:
        notify  => Service['postgresql'],
      }
    }

  }

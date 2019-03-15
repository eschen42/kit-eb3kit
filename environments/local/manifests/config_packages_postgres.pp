
#################################
##       Configurations        ##
#################################

class { 'vmbuilder_packages_postgres':

        bibboxbaseurl   => "eb3kit.bibbox.org",
        db_user         => "liferay",
        db_password     => "vendetta",
        db_name         => "lportal"
}


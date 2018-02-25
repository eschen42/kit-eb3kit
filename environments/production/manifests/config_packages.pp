
#################################
##       Configurations        ##
#################################

class { 'vmbuilder_packages':

        bibboxbaseurl   => "eb3kit.bibbox.org",
        db_user         => "liferay",
        db_password     => "bibbox4ever",
        db_name         => "lportal"
}

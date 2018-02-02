
#################################
##       Configurations        ##
#################################

class { 'vmbuilder':

        # General Kit Information
        # Currently only "eB3Kit" is available for bibboxkit
        bibboxkit       => "eB3Kit",
        bibboxbaseurl   => "eb3kit.bibbox.org",
        serveradmin     => "admin@bibbox.org",

        # Database Information
        db_user         => "liferay",
        db_password     => "bibbox4ever",
        db_name         => "lportal"

}

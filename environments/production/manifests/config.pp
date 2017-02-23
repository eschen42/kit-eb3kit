
#################################
##       Configurations        ##
#################################

class { 'vmbuilder':

	# General Kit Information
	bibboxkit		=> "eB3Kit",
	bibboxbaseurl		=> "eb3kit.bibbox.org",
	serveradmin		=> "admin@bibbox.org",

	# Database Information
	db_user			=> "liferay",
	db_password		=> "bibbox4ever",
	db_name			=> "lportal"

}


#############################################
##       Setup the operating system        ##
#############################################

class { 'vmbuilder_files':
        bibboxkit       => "eB3Kit",
        bibboxbaseurl   => "eb3kit.bibbox.org",
        serveradmin     => "admin@bibbox.org",
}



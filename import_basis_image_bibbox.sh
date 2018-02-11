#!/bin/bash
# curl -N https://raw.githubusercontent.com/bibbox/kit-eb3kit/master/import_basis_image_bibbox.sh | sudo bash -vn bibboxinstalltest -ssh 4022 -http 4080

echo "Import BIBBOX Basis OVA"

vmname_command=""
vmname="BIBBOX-v-2-0-2"
ova="bibbox-v-2-0-2_ubuntu_basis.ova"
p80="80"
p22="22"

import() {
	VBoxManage import $ova $vmname_command
}

setvmport() {
	VBoxManage modifyvm $vmname --natpf1 "ssh,tcp,127.0.0.1,$p22,,22"
	VBoxManage modifyvm $vmname --natpf1 "http,tcp,127.0.0.1,$p80,,80"
}

startvm() {
	VBoxManage startvm $vmname --type headless
}


while [ "$1" != "" ]; do
    case $1 in
        -vn | --vmname )        shift
								vmname=$1
                                vmname_command="--vsys 0 --vmname $vmname --vsys 0 --unit 11 --disk /root/VirtualBox VMs/$vmname/BIBBOX-v-2-0-2-disk001.vmdk"
                                ;;
        -ova | --ovafile )      shift
                                ova=$1
                                ;;
        -ssh | --ssh22 )        shift
                                p22=$1
                                ;;
        -http | --http80 )      shift
                                p80=$1
                                ;;
        * )                     usage
                                error_exit "Parameters not matching"
    esac
    shift
done

import
setvmport
startvm
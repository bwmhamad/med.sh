#!/bin/bash
#Utility script to (un)mount disks with dislocker
#Author: Mohammad Saad
#Github: https://github.com/bwmhamad/med.sh.git
#Dependencies: dislocker

_MED_MOUNT_SCRIPT=$(basename $0)

check_root()
{
	if [ "$EUID" -ne 0 ]; then
		echo "Please run $_MED_MOUNT_SCRIPT as root"
		usage
		exit 1
	fi
}

usage()
{
	echo "Usage:"
	echo "	$_MED_MOUNT_SCRIPT -m <disk-path> <disk-password>"
	echo "	$_MED_MOUNT_SCRIPT -u <disk-path>"
}

mnt()
{
	local disc=$1
	local password=$2
	local discname=$(basename $disc)
	mkdir -p "/media/disk-$discname"
	mkdir -p "/media/mount-$discname"
	dislocker -V $disc --user-password=$password -- /media/disk-$discname/
	mount -o loop /media/disk-$discname/dislocker-file /media/mount-$discname
}

umnt()
{
	local disc=$1
	local diskname=$(basename $disc)
	umount /media/mount-$diskname
	umount /media/disk-$diskname
	rm -rf /media/mount-$diskname
	rm -rf /media/disk-$diskname
}

main()
{
	check_root
	if [[ "$1" == "-m" ]]; then
		mnt $2 $3
	elif [[ "$1" == "-u" ]]; then
		umnt $2
	else
		usage
	fi
}
main $@

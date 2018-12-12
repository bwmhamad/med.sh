#!/bin/bash
#Mount Encrypted Disk: Utility script for linux (ubuntu) to mount BitLocker disks in similar way it works on Windows
#Author: Mohammad Saad
#Github: 
#Dependencies: zenity, lsblk, dislocker

#@TODO:Move all print into separate script to support shell only 
RED='\033[0;31m'
NC='\033[0m' # No Color
main()
{
	disc=$1
	password=$2
	discname=$(basename $disc)
	mkdir -p "/media/disk-$discname"
	mkdir -p "/media/mount-$discname"
	dislocker -V $disc --user-password=$password -- /media/disk-$discname/
	mount -o loop /media/disk-$discname/dislocker-file /media/mount-$discname
}

main $1 $2

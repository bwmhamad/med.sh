#!/bin/bash
#Mount Encrypted Disk: Utility script for linux (ubuntu) to mount BitLocker disks in similar way it works on Windows
#Author: Mohammad Saad
#Github: 
#Dependencies: zenity, lsblk, dislocker

if [[ "$1" == "-a" ]]; then
	newfavs=$(gsettings get com.canonical.Unity.Launcher favorites | sed "s/]/,'$2']/")
elif [[ "$1" == "-r" ]]; then
	newfavs=$(gsettings get com.canonical.Unity.Launcher favorites | sed -e "s/, '$2'//g")
else
	exit
fi
gsettings set com.canonical.Unity.Launcher favorites "$newfavs"

#!/bin/bash
#Script that handles addition and removal of MED icon to launcher. Tested on ubuntu.
#Author: Mohammad Saad
#Github: https://github.com/bwmhamad/med.sh.git
#Dependencies: gsettings

med_manage_launcher_icon()
{
	if [[ "$1" == "-a" ]]; then
		newfavs=$(gsettings get com.canonical.Unity.Launcher favorites | sed "s/]/,'$2']/")
	elif [[ "$1" == "-r" ]]; then
		newfavs=$(gsettings get com.canonical.Unity.Launcher favorites | sed -e "s/, '$2'//g")
	else
		exit
	fi
	gsettings set com.canonical.Unity.Launcher favorites "$newfavs"
}

med_manage_launcher_icon $@


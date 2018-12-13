#!/bin/bash
#Mount Encrypted Disk: Utility script for linux (ubuntu) to mount BitLocker disks in similar way it works on Windows
#Author: Mohammad Saad
#Github: https://github.com/bwmhamad/med.sh.git
#Dependencies: dislocker, zenity, lsblk

#below vars are used for app install only
SCRIPT=`realpath $0`
APPNAME=med.desktop
APPLOC=/home/$USER/.local/share/applications/$APPNAME
APPTEMP=template.app
DIR="$(dirname "$(readlink -f "$0")")"

get_disks_list()
{
	echo `lsblk -fpr | awk '/sda[0-9]/ { if($2 == "") print $1}' | sed 'N;s/\n/|/'`
}

show_dialog()
{
	disks=$(get_disks_list)
	if [ $isroot -eq 0 ];then
		local output=$(zenity --forms --separator=" " --timeout=30 --text "Mount Encrypted Disk" --add-combo disk --combo-values "$disks" --add-password "disk password" --add-password "sudo password")
	else
		local output=$(zenity --forms --separator=" " --timeout=30 --text "Mount Encrypted Disk" --add-combo disk --combo-values "$disks" --add-password "disk password")
	fi
	local accepted=$?
	if ((accepted == 0)); then
		echo $output
	elif ((accepted == 1)); then
		echo "cancelled"
	else
		echo "timeout"
	fi
}

un_mount()
{
	if [ "$isroot" == 0 ]; then
		echo "Please run this as root to unmount"
		exit
	fi
	diskname=$(basename $1)
	umount /media/mount-$diskname
	umount /media/disk-$diskname
	rm -rf /media/mount-$diskname
	rm -rf /media/disk-$diskname
}

app_install()
{	
	cp "$DIR/$APPTEMP" $APPLOC
	#if [ "$isroot" == 0 ]; then	
	#else
	#	sudo -u $USER cp "$DIR/$APPTEMP" $APPLOC
	#fi
	echo "Exec=$0" >> $APPLOC
	echo "Icon=$DIR/icon.png" >> $APPLOC
	$DIR/med-launcher.sh -a $APPNAME
}

app_remove()
{
	SCRIPT=`realpath $0`
	APPNAME=med.desktop
	APPLOC=/home/$USER/.local/share/applications/$APPNAME
	rm $APPLOC
	$DIR/med-launcher.sh -r $APPNAME
}

main()
{	
	opts=$(show_dialog)
	if [[ "$opts" == "cancelled" ]]; then
		echo "Mount cancelled by user"
		exit
	elif [[ "$opts" == "timout" ]]; then
		echo "No input received withing timeout period"
		exit
	fi

	read disk password sudopass <<<$opts
	if [ -z "$password" ]; then
		echo "Password cannot be empty"
		exit
	elif [ -z "$disk" ]; then
		echo "Disk cannot be empty"
		exit
	fi
	
	if [ "$isroot" == 1 ]; then
		/opt/med/mount.sh $disk $password
	elif ! [ -z "$sudopass" ]; then
		echo $sudopass | sudo -S $DIR/mount.sh $disk $password
	else
		sudo /opt/med/mount.sh $disk $password
	fi
}

if [ "$EUID" -ne 0 ]; then
	isroot=0
else
	isroot=1
fi

if [ $# -eq 2 ] && [ "$1" == "-u" ]; then
	un_mount $2
	exit
fi

if [ $# -eq 2 ] && [ "$1" == "-l" ]; then
	if [ "$2" == "install" ]; then
		app_install	
		exit
	elif [ "$2" == "remove" ]; then
		app_remove
		exit
	fi
fi

if [ $# -ne 0 ]; then
	scriptname=$(basename $0)
	echo "Usage:"
	echo "  $scriptname"
	echo "  $scriptname -l <install|remove>"
	echo "  $scriptname -u <disk-path>"
	echo "Mounts BitLocker disk with help of UI similar to Windows"
	echo ""
	echo "  -u          unmounts specified disk, previously mounted with med"
	echo "  -l          installs/uninstalls launcher application"
	exit
fi

main

#!/bin/bash
#Mount Encrypted Disk: Utility script for linux (ubuntu) to mount BitLocker disks with dislocker
#Author: Mohammad Saad
#Github: https://github.com/bwmhamad/med.sh.git
#Dependencies: dislocker, zenity, lsblk

#imports
_MED_DIR=$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))
source "$_MED_DIR/med-ui.sh"

#below consts are used for app install only
APPNAME=med.desktop
APPLOC=/home/$USER/.local/share/applications/$APPNAME
APPTEMP=template.app

#arguments
m=0
u=0
l=""
d=""

#below vars may change by the script
isroot=0

check_root()
{
	if [ "$EUID" -ne 0 ]; then
		isroot=0
	else
		isroot=1
	fi
}

usage()
{
	local scriptname=$(basename $0)
	echo "Usage:"
	echo "  $scriptname -m [disk-path] [OPTIONS...]"
	echo "  $scriptname -u [disk-path] [OPTIONS...]"
	echo "  $scriptname -l <install|remove> [OPTIONS...]"
	echo "Mounts BitLocker disk with help of GUI/CLI"
	echo ""
	echo "  -m          triggers ui to mount disk"
	echo "  -u          triggers ui to unmount disk"
	echo "  -d          disk path for unmounting. If this is specified, no ui is shown"
	echo "  -l          installs/uninstalls launcher application"
	echo "  -c          input/output through command line. Default is gui"
	echo "  -v          set verbose level: [1-6]"
}

get_disks_list()
{
	echo `lsblk -fpr | awk '/sda[0-9]/ { if($2 == "") print $1}'`
}

un_mount_ui()
{
	local disks=$(get_disks_list)
	local opts=$(med_ui_umount "$disks" $isroot)
	if [[ "$opts" == "cancelled" ]]; then
		log "Mount cancelled by user"
		exit
	elif [[ "$opts" == "timeout" ]]; then
		med_ui_message "No input received withing timeout period"
		exit
	fi
	echo $opts
	read disk sudopass <<< $opts
	if [ -z "$disk" ]; then
		med_ui_error "disk cannot be null"
		exit
	fi
	un_mount "$disk" "$sudopass"
}

un_mount()
{
	local disk=$1
	local sudopath=$2
	if [ "$isroot" == 1 ]; then
		$_MED_DIR/med-mount.sh -u "$disk"
	elif ! [ -z "$sudopass" ]; then
		echo $sudopass | sudo -S $_MED_DIR/med-mount.sh -u "$disk"
	else
		sudo $_MED_DIR/med-mount.sh -u "$disk"
	fi
}

app_install()
{	
	cp "$_MED_DIR/$APPTEMP" $APPLOC
	#if [ "$isroot" == 0 ]; then
	#else
	#	sudo -u $USER cp "$DIR/$APPTEMP" $APPLOC
	#fi
	echo "Exec=$0 -m" >> $APPLOC
	echo "Icon=$_MED_DIR/icon.png" >> $APPLOC
	echo "[Desktop Action Med-Unmount]" >> $APPLOC
	echo "Name=Unmount Disk" >> $APPLOC
	echo "Exec=$0 -u" >> $APPLOC
	$_MED_DIR/med-launcher.sh -a $APPNAME
}

app_remove()
{
	rm $APPLOC
	$_MED_DIR/med-launcher.sh -r $APPNAME
}

parse_args()
{
	local jobs_c=0
	while getopts ":l:ucmv:" o; do
		case "${o}" in
			l)
				l=${OPTARG}
				if ! [ "$l" == "install" ] && ! [ "$l" == "remove" ]; then
					usage
					exit
				fi
				((jobs_c++))
				;;
			u)
				u=1
				((jobs_c++))
				;;
			c)
				med_ui_cli
				;;
			m)
				m=1
				((jobs_c++))
				;;
			d)
				d=${OPTARG}
				((jobs_c++))
				;;
			v)
				log_set_level ${OPTARG}
				;;
			*)
				usage
				exit
				;;
		esac
	done
	shift $((OPTIND-1))

	if [ $jobs_c -gt 1 ]; then
		usage
		exit
	fi
}

mount_ui()
{
	local disks=$(get_disks_list)
	local opts=$(med_ui_mount "$disks" $isroot)
	if [[ "$opts" == "cancelled" ]]; then
		log "Mount cancelled by user"
		exit
	elif [[ "$opts" == "timeout" ]]; then
		med_ui_message "No input received withing timeout period"
		exit
	fi

	read disk password sudopass <<<$opts
	if [ -z "$password" ]; then
		med_ui_error "Password cannot be empty"
		exit
	elif [ -z "$disk" ]; then
		med_ui_error "Disk cannot be empty"
		exit
	fi
	
	if [ "$isroot" == 1 ]; then
		$_MED_DIR/med-mount.sh -m $disk $password
	elif ! [ -z "$sudopass" ]; then
		echo $sudopass | sudo -S $_MED_DIR/med-mount.sh -m $disk $password
	else
		sudo $_MED_DIR/med-mount.sh -m $disk $password
	fi
}

main()
{	check_root
	parse_args $@
	if ! [ -z "$l" ]; then
		app_$l
	elif [ $u -eq 1 ]; then
		if ! [ -z "$d" ]; then
			un_mount $d
		else
			un_mount_ui
		fi
	elif [ $m -eq 1 ]; then
		mount_ui
	else
		usage
	fi
}

main $@

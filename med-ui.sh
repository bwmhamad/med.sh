#!/bin/bash
#Script that handles UI for MED
#Author: Mohammad Saad
#Github: https://github.com/bwmhamad/med.sh.git
#Dependencies: zenity

_MED_UI_DIR=$(dirname $([ -L $0 ] && readlink -f $0 || echo $0))
source "$_MED_UI_DIR/logger.sh"

UI_FORM="gui"
APP_NAME="Mount Encrypted Disk"

med_ui_mount_gui()
{
	local disks=$1
	local isroot=$2
	local disks=$(echo $disks | sed 's/[ \n\t]/|/g')
	local output=''
	local accepted=1
	if [ $isroot -eq 0 ];then
		output=$(zenity --forms --separator=" " --timeout=30 --text "$APP_NAME" --add-combo disk --combo-values "$disks" --add-password "disk password" --add-password "sudo password")
		accepted=$?
	else
		output=$(zenity --forms --separator=" " --timeout=30 --text "$APP_NAME" --add-combo disk --combo-values "$disks" --add-password "disk password")
		accepted=$?
	fi
	if ((accepted == 0)); then
		echo $output
	elif ((accepted == 1)); then
		echo "cancelled"
	else
		echo "timeout"
	fi
}

med_ui_mount_cli()
{
	local disks=$1
	local isroot=$2
	log_stdout "$APP_NAME:"
	local i=1
	for d in $disks; do
		log_stdout "[$i]\t$d"
		i=$(($i + 1))
	done
	read -p 'select:' opt
	local disk=$(echo $disks | cut -d " " -f $opt)
	read -sp 'disk password: ' diskpass
	log_stdout ""
	if [ $isroot -eq 0 ];then
		read -sp 'sudo password: ' sudopass
		log_stdout ""
	else
		local sudopass=""
	fi
	echo "$disk $diskpass $sudopass"
}

##
#@param disks | separated list of disks to mount
#@param is_root
#@return timeout|cancelled|space separated values of disk,password,sudo
##
med_ui_mount()
{
	med_ui_mount_$UI_FORM "$@"
}

med_ui_umount_gui()
{
	local disks=$1
	local isroot=$2
	local disks=$(echo $disks | sed 's/[ \n\t]/|/g')
	local output=''
	local accepted=1
	if [ $isroot -eq 0 ];then
		output=$(zenity --forms --separator=" " --timeout=30 --text "$APP_NAME (Unmount)" --add-combo disk --combo-values "$disks" --add-password "sudo password")
		accepted=$?
	else
		output=$(zenity --forms --separator=" " --timeout=30 --text "$APP_NAME (Unmount)" --add-combo disk --combo-values "$disks")
		accepted=$?
	fi
	if ((accepted == 0)); then
		echo $output
	elif ((accepted == 1)); then
		echo "cancelled"
	else
		echo "timeout"
	fi
}

med_ui_umount_cli()
{
	local disks=$1
	local isroot=$2
	log_stdout "$APP_NAME (UNMOUNT):"
	local i=1
	for d in $disks; do
		log_stdout "[$i]\t$d"
		i=$(($i + 1))
	done
	read -p 'select:' opt
	local disk=$(echo $disks | cut -d " " -f $opt)
	if [ $isroot -eq 0 ];then
		read -sp 'sudo password: ' sudopass
		log_stdout ""
	else
		local sudopass=""
	fi
	echo "$disk $diskpass $sudopass"
}

med_ui_umount()
{
	med_ui_umount_$UI_FORM "$@"
}

med_ui_message_gui()
{
	zenity --info --text="$1"
}

med_ui_message_cli()
{
	log $INFO "$1"
}

med_ui_message()
{
	med_ui_message_$UI_FORM "$@"
}

med_ui_error_gui()
{
	zenity --error --text="$1"
}

med_ui_error_cli()
{
	log $ERROR "$1"
}

med_ui_error()
{
	med_ui_error_$UI_FORM "$@"
}

med_ui_gui()
{
	UI_FORM="gui"
}

med_ui_cli()
{
	UI_FORM="cli"
}

#Universal Logger: Simple logger used in various projects
#Author: Mohammad Saad
#License: MIT
#Dependencies: 'none'

INFO=3
WARN=4
ERROR=5
OFF=7

_log_level=4

_pad_string()
{
	printf "%-${2}s" "$1"
}

_log_mapper()
{
	if [ $1 -eq $INFO ]; then
		echo "INFO"
	elif [ $1 -eq $WARN ]; then
		echo "WARN"
	elif [ $1 -eq $ERROR ]; then
		echo "EROR"
	else
		echo $1
	fi
}

log()
{
	local msg=""
	local level=""
	if [ $# -eq 2 ]; then
		msg=$2
		level=$1
	elif [ $# -eq 1 ]; then
		level=1
		msg=$1
	else
		level=1
		msg=$@
	fi
	if [ $level -lt $_log_level ]; then
		return
	fi
	local now=`date '+%Y-%m-%d %H:%M:%S'`
	local type=$(_log_mapper $level)
	#echo "$now | (${FUNCNAME[1]}) - [$type]: $msg" 1>&2;
	printf '\r%s | %-10s - %-6s: %s\n' "$now" "(${FUNCNAME[1]})" "[$type]" "$msg" 1>&2
}

log_set_level()
{	
	if [ $# -eq 1 ]; then
		_log_level=$1
	else
		_log_level=3
	fi
}

log_usage()
{
	local message=$@
	log $(_pad_string $ERROR 7) "Usage: ${FUNCNAME[1]} $message"
}

log_stdout()
{
	printf "$@\n" 1>&2
}

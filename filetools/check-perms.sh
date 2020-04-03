#!/usr/bin/env bash
# Very basic script to set proper permissions and ownerships
#
# TODO check rights and security flaws
# TODO handle errors
# TODO localisation
# TODO logging
# TODO replace echo with printf
#
# Functions
function param-read () {
	param=$(grep "^$1" ${CONF} | sed "s/^$1 *= *//")
	echo ${param}
}
function perm-check () {
	echo "Looking for improper permissions and group ownerships"
	find . -type f ! -type l ! -perm $3 -exec ls -l {} \;
	find . -type d ! -perm $4 -exec ls -l {} \;
	find . ! -type l ! -user $1 -exec ls -l {} \;
	find . ! -type l ! -group $2 -exec ls -l {} \;
}
function perm-mod () {
	echo "Correcting any errors"
	find . -type f ! -type l ! -perm $3 -exec chmod $3 {} \;
	find . -type d ! -perm $4 -exec chmod $4 {} \;
	find . ! -type l ! -user $1 -exec chown $1:$2 {} \;
	find . ! -type l ! -group $2 -exec chown $1:$2 {} \;
}
#
# Configuration file lookup
if [ -f /usr/local/etc/check-perms/local.conf ]; then
	CONF="/usr/local/etc/check-perms/local.conf"
elif [ -f /usr/local/etc/check-perms/check-perms.conf ]; then
	CONF="/usr/local/etc/check-perms/check-perms.conf"
elif [ -f /usr/local/etc/check-perms.conf ]; then
	CONF="/usr/local/etc/check-perms.conf"
elif [ -f /etc/check-perms/local.conf ]; then
	CONF="/etc/check-perms/local.conf"
elif [ -f /etc/check-perms/check-perms.conf ]; then
	CONF="/etc/check-perms/check-perms.conf"
elif [ -f /etc/check-perms.conf ]; then
	CONF="/etc/check-perms.conf"
else
	echo "Configuration file not found, exiting!" 1>&2
	echo "Should be in either /etc, /etc/check-perms" 1>&2
	echo "/usr/local/etc or /usr/local/etc/check-perms," 1>&2
	echo "either as check-perms.conf in any of these locations" 1>&2
	echo "or as local.conf in the check-perms directory" 1>&2
	echo "with the last having higher precedence." 1>&2
	exit 1
fi
#
# Startup tests
CUR=$(whoami)
WKD=$(pwd)
if [[ $EUID -eq 0 ]]; then
	echo "This script must not be run as root" 1>&2
	exit 1
fi
if [[ ${WKD} == /home/${CUR} ]]; then
	echo "Should not be run in home directory, cd to /data/somedir first!" 1>&2
	exit -1
fi
#
# Configuration reading # TODO add parametric input
USR=$(param-read "USR")
GRP=$(param-read "GRP")
FIL=$(param-read "FIL")
DIR=$(param-read "DIR")
#
# Effective run
echo "We are going to reset ownership to ${USR}:${GRP},"
echo "with values ${FIL} for files and ${DIR} for directories."
perm-check ${USR} ${GRP} ${FIL} ${DIR}
#exit 0# Exit here if you only want to check # TODO add parametric input
perm-mod ${USR} ${GRP} ${FIL} ${DIR}
echo "Finished"

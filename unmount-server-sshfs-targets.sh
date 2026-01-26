#!/usr/bin/env bash
# Unmount sshfs shares on local machine
# Setup requires a configuration directory parallel containing this executable
# in which a mount_targets.conf file holds the settings using this format :
# username:hostname:target_directory:local_directory:comment(optional)
# one target per line, empty lines and lines starting with # are ignored
set -e
################################################################################
# Global settings
INSTALLDIR=/home/user/.local/bin/
CONFDIR=../conf
MOUNTTARGETS=mount_targets.conf
MOUNTDIR=/home/user/Mount/sshfs/
################################################################################
# Functions
effectiveUnmount() {
	# Runs all the effective unmount tests
	# and carries out the unmount proper
	# requires one parameter containing mount settings
	local T_USER=`echo ${1} | cut -d":" -f 1`
	local T_HOST=`echo ${1} | cut -d":" -f 2`
	local T_SRC=`echo ${1} | cut -d":" -f 3`
	local T_DEST=`echo ${1} | cut -d":" -f 4`
	echo "Unmounting directory '${T_SRC}' from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}'"
	if [[ $(mount -l | grep "${T_USER}@${T_HOST}:${T_SRC}") != "" ]]; then
		{
			fusermount -u ${MOUNTDIR}${T_DEST} &&
				echo " We have unmounted \
'${T_SRC}' mount from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}' \
successfully."
		} || {
			echo " Unmounting of \
'${T_SRC}' mount from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}' \
has failed."
		}
	else
		echo " Share point not mounted. \
Unmounting not required."
	fi
}
################################################################################
# Main
if [ ! -d ${INSTALLDIR}${CONFDIR} ]; then
	echo "(EE) Configuration directory not found."
	exit -1
elif [ ! -f ${MOUNTARGETS} ]; then
	echo "(EE) Mount targets configuration file not found."
	exit -1
elif [ ! -d ${MOUNTDIR} ]; then
	echo "(EE) Mount root directory not found."
	exit -1
else
	TARGETS=`egrep -v "^$|^#" ${INSTALLDIR}${CONFDIR}/${MOUNTTARGETS}`
	for TARGET in ${TARGETS}; do
		effectiveUnmount ${TARGET} &
	done
fi
wait
echo "========================================"
echo "Network drives unmounting complete."

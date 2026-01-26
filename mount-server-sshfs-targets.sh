#!/usr/bin/env bash
# Mount sshfs shares on local machine
# Setup requires a configuration directory parallel containing this executable
# in which a mount_targets.conf file holds the settings using this format :
# username:hostname:target_directory:local_directory:comment(optional)
# one target per line, empty lines and lines starting with # are ignored
set -e
################################################################################
# Global settings
# TODO move to ini/conf file
# TODO put all params in the same file, targets and config?
# TODO pass configuration as cli parameter
INSTALLDIR=/home/user/.local/bin/
CONFDIR=../conf
MOUNTTARGETS=sshfs-targets.conf
MOUNTDIR=/home/user/Mount/sshfs/
HOST=Munin
################################################################################
# Functions
effectiveMount() {
	# Runs all the effective mount tests
	# and carries out the mount proper
	# requires one parameter containing mount settings
	SKIPMOUNT=0
	local T_USER=`echo ${1} | cut -d":" -f 1`
	local T_HOST=`echo ${1} | cut -d":" -f 2`
	local T_SRC=`echo ${1} | cut -d":" -f 3`
	local T_DEST=`echo ${1} | cut -d":" -f 4`
	# TODO output message construction
	#local effectiveMountMsg01=""
	echo "Mounting directory '${T_SRC}' from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}'" &
	if [[ ${T_DEST} == "" ]]; then
		echo "(WW) Destination mount point for host ${T_HOST} \
is empty, this \
is probably not desired and will probably \
break things, \
skipping this mount."
		SKIPMOUNT=1
	elif [[ ${T_DEST} == "/" ]]; then
		echo "(WW) Destination mount point for host ${T_HOST} \
is mount root, \
this is probably not desired and will \
probably break things, \
skipping this mount."
		SKIPMOUNT=1
	elif [ ! -d ${MOUNTDIR}${T_DEST} ]; then
		{
			mkdir ${MOUNTDIR}${T_DEST} &&
				echo "We have created ${T_DEST} \
mount point :"
		       echo "`ls -ld ${MOUNTDIR}${T_DEST}`"
		} || {
			echo "(WW) Destination mount point directory \
for host ${T_HOST} \
does not exist, skipping this mount."
			SKIPMOUNT=1
		}
	fi
	if [[ ${SKIPMOUNT} == "0" ]]; then
		if [[ $(mount -l | grep "${T_USER}@${T_HOST}:${T_SRC}") == "" ]]; then
			{
				sshfs ${T_USER}@${T_HOST}:${T_SRC} ${MOUNTDIR}${T_DEST} &&
					echo "We have mounted \
'${T_SRC}' from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}' \
successfully."
			} || {
				echo "Mounting of \
'${T_SRC}' from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}' \
has failed."
			}
		fi
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
		effectiveMount ${TARGET} &
	done
fi
wait
echo "Mounting sshfs network drives from host ${HOST} complete."

#!/usr/bin/env bash
# Analyse network interface evolution
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
LOGDIR=../log
LOGFILE=interface-status-history.log
STATFILE=current-interface-status.log
RECFILE=recorded-interface-status.log
LOG=${LOGDIR}/${LOGFILE}
STAT=${LOGDIR}/${STATFILE}
REC=${LOGDIR}/${RECFILE}
################################################################################
# Functions
listInterfaceStatus() {
	sudo ip -br a | egrep "enp0s31f6|wlp2s0"
}
################################################################################
# Main
cd ${INSTALLDIR}
while true; do
	interfaceStatus=$( sudo ip -br a | egrep "enp0s31f6|wlp2s0" )
	echo $interfaceStatus > ${STAT}
	if [ -e ${LOG} ] && [ -e ${REC} ]; then
		currentStatus=$( cat ${STAT} )
		#echo "current status =   $currentStatus"
		recordedStatus=$( cat ${REC} )
		#echo "previous status =  $recordedStatus"
		if [[ $currentStatus != $recordedStatus ]]; then
			#echo "interfaces have changed"
			echo $currentStatus > ${REC}
			echo $(date) >> ${LOG}
			echo $interfaceStatus >> ${LOG}
		else
			#echo "interfaces are the same"
			continue
		fi
	else
		if [ -e ${REC} ]; then
			touch ${LOG}
		else
			touch ${REC}
			echo $interfaceStatus > ${REC}
		fi
	fi
	sleep 55
done

#if [ ! -d ${INSTALLDIR}${CONFDIR} ]; then
#	echo "(EE) Configuration directory not found."
#	exit -1
#elif [ ! -f ${MOUNTARGETS} ]; then
#	echo "(EE) Mount targets configuration file not found."
#	exit -1
#elif [ ! -d ${MOUNTDIR} ]; then
#	echo "(EE) Mount root directory not found."
#	exit -1
#else
#	TARGETS=`egrep -v "^$|^#" ${INSTALLDIR}${CONFDIR}/${MOUNTTARGETS}`
#	for TARGET in ${TARGETS}; do
#		effectiveMount ${TARGET} &
#	done
#fi
#wait
#echo "========================================"
#echo "Network drives mounting complete."

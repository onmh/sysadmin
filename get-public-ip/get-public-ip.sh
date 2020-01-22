#!/usr/bin/env bash
# Query online services to determine public IP
# and send notification if change is detected
# O. Henriot, 20/01/2020
# TODO re-write resolution routines as function
# TODO re-write mail send as function
# TODO error handling
HOST=`hostname`
TS=`date +%Y%m%d%H%M%S`
INSTALL_DIR=/usr/local/etc/get-public-ip/
CONF_FILE=${INSTALL_DIR}setup.conf
VAL_STORE=${INSTALL_DIR}current-value
VAL_HISTORY=${INSTALL_DIR}public-ip.log
RES_ROUTINES=${INSTALL_DIR}resolv-routines.conf
VAL_RANK=0
# Requires bash 4
declare -A MY_PUBLIC_IP_VALS
# Use multiple routines to resolve public IP
CUR_VAL="No current value yet"
VAL_DIF=0
#MY_PUBLIC_IP=`curl ipinfo.io/ip 2>/dev/null`
while read LINE; do
	#echo $LINE
	VAL=`echo ${LINE} | egrep -v "^#|^$|^  *"`
	if [ "${VAL}" != "" ]; then
		let "VAL_RANK++"
		#echo $VAL
		MY_PUBLIC_IP=`${VAL} 2>/dev/null`
		#echo "Current value: $CUR_VAL, my IP: $MY_PUBLIC_IP, value difference: $VAL_DIF"
		if [[ "${CUR_VAL}" == "No current value yet" ]]; then
			#echo "No current value yet, assigning $MY_PUBLIC_IP"
			CUR_VAL=${MY_PUBLIC_IP}
			#echo "Current value now is $CUR_VAL"
		elif [ "${CUR_VAL}" != "${MY_PUBLIC_IP}" ]; then
			#echo "Found a different result of public IP lookup, incrementing $VAL_DIF"
			let "VAL_DIF++"
		fi
		#echo "Current value after this loop is $CUR_VAL"
		#echo $MY_PUBLIC_IP
		MY_PUBLIC_IP_VALS[${VAL_RANK}]=${MY_PUBLIC_IP}
	fi
done < ${RES_ROUTINES}
# -----
#echo $VAL_DIF
if [ "${VAL_DIF}" != "0" ]; then
	echo "Not all values found are the same!"
	for CUR_RANK in "${!MY_PUBLIC_IP_VALS[@]}"; do echo "${CUR_RANK} - ${MY_PUBLIC_IP_VALS[${CUR_RANK}]}"; done
#else
#	echo "My public IP is $MY_PUBLIC_IP"
fi
#exit 0
PREVIOUS_VAL=`cat ${VAL_STORE}`
if [ "${MY_PUBLIC_IP}" != "${PREVIOUS_VAL}" ]; then
	while read LINE; do
		VAL=`echo ${LINE} | grep "^maildest" | sed 's/^maildest=//'`
		if [ "${VAL}" != "" ]; then
			echo "At timestamp ${TS} we notice that ${HOST} public ip has changed to ${MY_PUBLIC_IP} from previous value ${PREVIOUS_VAL}" | mail -s "${HOST} public ip has changed" ${VAL}
		fi
	done < ${CONF_FILE}
	#echo "At timestamp $TS we notice that $HOST public ip has changed to $MY_PUBLIC_IP from previous value $PREVIOUS_VAL"
	echo ${MY_PUBLIC_IP} > ${VAL_STORE}
	echo "${TS},${MY_PUBLIC_IP}" >> ${VAL_HISTORY}
#else
#	while read LINE; do
#		VAL=`echo $LINE | grep "^maildest" | sed 's/^maildest=//'`
#		if [ "$VAL" != "" ]; then
#			echo "Current public ip, $MY_PUBLIC_IP, at timestamp $TS, is the same as previous recorded value." | mail -s "$HOST public ip has not changed" $VAL
#		fi
#	done < $CONF_FILE
#	echo "Current public ip, $MY_PUBLIC_IP, at timestamp $TS, is the same as previous recorded value."
fi

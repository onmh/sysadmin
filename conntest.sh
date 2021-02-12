#!/usr/bin/env bash
################################################################################
# Test a server port with netcat
# send an email upon successful connection if mail is available
# Should check netcat is available TODO
# Make make messages parametric TODO
# Functions TODO
################################################################################
# Define in configuration file TODO
# Mail destination
maildest=Joe.Blogs@fixme
# Connection attempt timeout in seconds
tou=10
################################################################################
# Check number of arguments and point to help if none, could fall back to
# defaults if none provided rather than exiting? TODO
if [ $# -lt 2 ]; then
	printf "\n     Usage: `basename $0` <hostname> <port>\n\n"
	exit 65
fi
################################################################################
# Totaly useless while argument check causes exit, but what the heck,
# when defaults will be used instead will be usefull TODO...
if [ -z ${1+x} ]; then
	printf "\nHostname and port missing, will use defaults (localhost,22).\n"
	srv=localhost
	prt=22
else
	srv=$1
fi
if [ -z ${2+x} ]; then
	printf "\nPort missing, will use default (22).\n"
	prt=22
else
	prt=$2
fi
################################################################################
# Look for mail binary and warn if not found
# No check to test if setup is OK and user is allowed to send mail, TODO
mailbin=$(which mail)
if [ "${mailbin}" == "" ]; then
	printf "\n\n  /!\\ Mail binary not found, sending result by mail will fail!\n"
fi
################################################################################
################################################################################
up=0
################################################################################
# so long as server is not up we test
while [ $up == 0 ]; do
	printf "\n  =====================\nTesting:\n - server: ${srv}\n - port: ${prt}\n - timeout: ${tou} seconds\n - timestamp: $(date)\n"
	res=$(nc -4 -w${tou} -z ${srv} ${prt} && printf $?)
	# nc returns 0 (false) on success, so if false, then server is up...
	if [ "$res" != "0" ] && [ "$res" != "1" ]; then
		printf "\nServer did not respond within ${tou} seconds timeout.\n"
		res=1
	fi
	if [ "$res" == "0" ]; then
		up=1
		printf "\nServer ${srv} is up and listening on port ${prt}, reply received before the ${tou} seconds timeout on $(date)!\n"
		if [ -x ${mailbin} ] && [ "${mailbin}" != "" ]; then
			printf "\nServer ${srv} is up and listening on port ${prt}, reply received before the ${tou} seconds timeout on $(date)!\n" | mail -s "Server test successful" ${maildest}
		fi
	else
		printf "\nServer ${srv} is not reachable on port ${prt} within the ${tou} seconds timeout, will retry in a minute.\n"
		sleep 60
	fi
done
################################################################################

#!/usr/bin/env bash
if [ $# -ne 1 ]; then
	printf "\n\n     Usage: `basename $0` <host definition file>\n\n"
	exit 65
fi
#UPDATE=0
#LIST=0
UPLIST=0
#UPGRADE=0
#FULLUP=0
#FIXBRK=0
#FIXMIS=0
TOTUP=0
HELP=0
while getopts ":ut:h" Option; do
	case $Option in
		u) UPLIST=1;;
		t) TOTUP=1;;
		h) HELP=1;;
		?) echo "Unrecognized option. Exit 7" ;;
	esac
done
if [ HELP = 0 ] && [ $# -lt 1 ]; then
	echo "input file not found"
	exit 0
fi
infile="${1}"
while read line; do
	echo " === ${line} ==="
	#ssh ${line} "sudo apt update && sudo apt list --upgradable" &
	ssh ${line} "sudo apt full-upgrade -y && sudo apt install --fix-broken && sudo apt install --fix-missing" &
	#ssh ${line} "sudo apt autoclean" &
done<${infile}

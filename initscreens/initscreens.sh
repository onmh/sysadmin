#!/usr/bin/env bash
# init screens

if (( $# != 1 )); then
	echo "========================================"
	echo " Illegal number of parameters"
	echo "          ===================="
	echo " Usage: $0 <screen conf file>"
	echo " Configuration file is one triplet per line"
	echo " Triplet is: name,first[0-9][0-9]*,last[0-9][0-9*]"
	echo " Name starts with alnum"
	echo " Comments start with #"
	echo " Empty lines are ignored"
	echo "========================================"
	echo ""
	exit -1
fi


########################################
# Functions
####################
# init screens, call by passing (pattern, start and end)
function init_screen () {
  declare -i first last
  first=$2
  last=$3
  printf "\n  == Init of screens $1, from $2 to $3 ==\n"
  if [ ! -z "$(screen -ls | grep "$1")" ]; then
    printf "  A screen with a name similar to $1 exists\n";
    echo $(screen -ls | grep "$1")
  else
    printf "  No screens exist for $1, creating them\n"
    for i in $(seq $first $last); do
      $(screen -m -d -S $1-$i)
    done
  fi
  printf "  == ==\n"
}

# build call
function build_call () {
	while read line; do
		input=$(echo $line | grep "^[[:alnum:]].*[[:alnum:]]*,[[:digit:]][[:digit:]]*,[[:digit:]][[:digit:]]*" | sed 's/\#.*$//')
		# TODO sanitization of name?
		if [ -n "$input" ]; then
			sname=$(echo $line | cut -d "," -f 1)
			first=$(echo $line | cut -d "," -f 2)
			last=$(echo $line | cut -d "," -f 3)
			#echo "Line is $sname $first $last"
			#echo "Calling init_screen $sname $first $last"
			# TODO sanitization? check number of screens to create below a threshold?
			init_screen $sname $first $last
		fi
	done < $1
}

########################################
# Define function calls

####################
build_call $1

####################


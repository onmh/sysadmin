#!/usr/bin/env bash

usage="\nUsage: `basename ${0}` {target}\n\n"
if [ $# -lt 1 ]
then
	echo -e ${usage}
	exit 0
fi
rsync -aihHAX --delete /home/henrioto/.ssh/ ${1}/.ssh/
rsync -aihHAX --delete /home/henrioto/.local/custom/ ${1}/.local/custom/
cp -af /home/henrioto/.tmux.conf ${1}
cp -af /home/henrioto/.profile ${1}
cp -af /home/henrioto/.bash_aliases ${1}
cp -af /home/henrioto/.bashrc ${1}

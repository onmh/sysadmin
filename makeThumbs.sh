#!/usr/bin/env bash

#for friendDir in `ls -1`; do
currDir=$(pwd);
if [ "${currDir}" == "/" ]; then
	echo "Should probably not be working at filesystem root."
	exit 1
elif [ "${currDir}" == "" ]; then
	echo "Current directory is empty, this should not happen."
	exit 1
#else
#	echo ${currDir}
fi
#exit 0
for friendDir in $(find . -maxdepth 1 -type d); do
	noFiles=false
#	echo "testing file presence"
#	if [ ! -f "*.jpg" ]; then
	if [ "$(ls ${friendDir}/*.jpg 2>/dev/null)" == "" ]; then
		noFiles=true
	fi
#	echo $noFiles
#	echo "file presence tested"
	if [ "${noFiles}" == "false" ]; then
		echo "   -----   ${friendDir}   -----"
		cd ${friendDir};
#		echo "inside friend dir"
		rename 's/ /_/' *.*;
#		echo "files renamed"
		for img in `ls -1 *.jpg 2>/dev/null`; do
#			echo "treating image ${img}"
			out=`basename -a -s ".jpg" ${img}`;
			if [ ! -f ${out}_thumb.png ]; then
#				echo ${out}_thumb.png
				convert ${img} -resize 20% ${out}_thumb.png;
			fi
#			echo "image ${img} treated"
		done
#		echo "directory ${friendDir} done"
		cd ${currDir};
#		echo "back in ${currDir}"
	fi
done
echo "All done!"

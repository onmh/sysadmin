#!/usr/bin/env bash
EXPECTED_ARGS=1
E_BADARGS=65
BASH=`which bash`

if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: `basename $0` {dev (e.g. sdc1)}"
  exit $E_BADARGS
fi

DEVICE=$1

#echo $DEVICE
#command="sudo tcplay -m truecryptkey -d /dev/${DEVICE}"
#echo $command

echo "Running script to mount a TrueCrypt USB stick."
echo "Device is /dev/${DEVICE}"
echo "Attempting to map the device to /dev/mapper/truecryptkey"
sudo tcplay -m truecryptkey -d /dev/${DEVICE}
echo "Attempting to mount mapped device to /mnt/truecryptkey"
sudo mount /dev/mapper/truecryptkey /mnt/truecryptkey
echo "Script finished"

#!/usr/bin/env bash

echo "Running script to unmount a TrueCrypt USB stick."
echo "Attempting to unmount mapped device from /mnt/truecryptkey"
sudo umount /mnt/truecryptkey/
echo "Attempting to remove /dev/mapper/truecryptkey device mapping"
sudo cryptsetup remove truecryptkey
echo "Script finished"

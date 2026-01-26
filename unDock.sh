#!/usr/bin/env bash
# Prepare to remove from dock
# Remove all mounted external drives and remote shares
# TODO
# need to add per network status actions
# - when wired eth0 connected and ip = @work then start cups
# - when wired eth0 disconnected and ip = @work then stop cups
set -e
################################################################################
# Global settings
INSTALLDIR=/home/user/.local/bin/
CONFDIR=../conf
################################################################################
# Network drives (TODO should be network settings dependant)
${INSTALLDIR}/unmountNetworkDrives.sh
# automounted devices (Debian way, TODO add Nixos way ?)
for mounted in $(mount -l | grep /media/$(whoami)/ | cut -d " " -f 3); do
	umount ${mounted};
done
# backintime specific (superfluous with autmounted devices unmounting)
if [[ $( mount -l | grep "/run/media/user/backintime") != "" ]]; then
	umount /run/media/user/backintime
fi
if [[ $( mount -l | grep "/media/user/backintime") != "" ]]; then
	umount /media/user/backintime
fi
wait
echo "========================================"
echo "Undocking complete."

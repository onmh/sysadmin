#!/usr/bin/env bash
# Mount/unmount sshfs shares on local machine
# Setup requires a configuration directory parallel containing this executable
# in which a mount_targets.conf file holds the settings using this format :
# username:hostname:target_directory:local_directory:comment(optional)
# one target per line, empty lines and lines starting with # are ignored
# Command line logic:
# server-sshfs-targets.sh [-m|-u] conf-file
# -m|-u specifies action, mount/unmount, mandatory, only one of the two
# conf-file mandatory configuration file
set -e
###############################################################################
# Default variables
ERR_BADARGS=65
MOUNT=0
UNMOUNT=0
HELP=0
USAGE="\n\n     Usage: `basename $0` [-m|-u] <configuration file>\n\n"
# Command line arguments
while getopts ":mu:h" Option; do
    case $Option in
        m) MOUNT=1;;
        u) UNMOUNT=1;;
        h) HELP=1;;
        ?) echo "Unrecognized option. Exit 7" && exit 7 ;;
    esac
done
# TODO printf and echo to stderr
if [ $# -ne 2 ]; then
    echo -e ${USAGE}
    exit ${ERR_BADARGS}
elif [ "${HELP}" == "0" ] && [ $# -lt 2 ]; then
        echo "Input file not found"
        exit ${ERR_BADARGS}
elif [ $# -lt 2 ] && [ $1 == '-h' ]; then
    echo -e ${USAGE}
    exit 0
elif [ $# -lt 2 ]; then
    echo -e ${USAGE}
    exit ${ERR_BADARGS}
elif [ "${1}" == "-h" ]; then
    echo -e ${USAGE}
    exit 0
fi
CONFIG_FILE="${2}"

################################################################################
# Functions
effectiveMount() {
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # Runs all the effective mount tests
    # and carries out the mount proper
    # requires one parameter containing mount settings
    SKIP_MOUNT=0
    local T_USER=`echo ${1} | cut -d":" -f 1`
    local T_HOST=`echo ${1} | cut -d":" -f 2`
    local T_SRC=`echo ${1} | cut -d":" -f 3`
    local T_DEST=`echo ${1} | cut -d":" -f 4`
    # TODO output message construction
    #local effectiveMountMsg01=""
    echo "Mounting directory '${T_SRC}' from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}'" &
    if [[ ${T_DEST} == "" ]]; then
        echo "(WW) Destination mount point for host ${T_HOST} \
is empty, this \
is probably not desired and will probably \
break things, \
skipping this mount."
        SKIP_MOUNT=1
    elif [[ ${T_DEST} == "/" ]]; then
        echo "(WW) Destination mount point for host ${T_HOST} \
is mount root, \
this is probably not desired and will \
probably break things, \
skipping this mount."
        SKIP_MOUNT=1
    elif [ ! -d ${MOUNT_DIR}${T_DEST} ]; then
        {
            mkdir ${MOUNT_DIR}${T_DEST} &&
                echo "We have created ${T_DEST} \
mount point :"
                echo "`ls -ld ${MOUNT_DIR}${T_DEST}`"
        } || {
            echo "(WW) Destination mount point directory \
for host ${T_HOST} \
does not exist, skipping this mount."
            SKIP_MOUNT=1
        }
    fi
    if [[ ${SKIP_MOUNT} == "0" ]]; then
        if [[ $(mount -l | grep "${T_USER}@${T_HOST}:${T_SRC}") == "" ]]; then
            {
                sshfs ${T_USER}@${T_HOST}:${T_SRC} ${MOUNT_DIR}${T_DEST} &&
                    echo "We have mounted \
'${T_SRC}' from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}' \
successfully."
            } || {
                echo "Mounting of \
'${T_SRC}' from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}' \
has failed."
            }
        fi
    fi
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
}

effectiveUnmount() {
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # Runs all the effective unmount tests
    # and carries out the unmount proper
    # requires one parameter containing mount settings
    local T_USER=`echo ${1} | cut -d":" -f 1`
    local T_HOST=`echo ${1} | cut -d":" -f 2`
    local T_SRC=`echo ${1} | cut -d":" -f 3`
    local T_DEST=`echo ${1} | cut -d":" -f 4`
    echo "Unmounting directory '${T_SRC}' from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}'"
    if [[ $(mount -l | grep "${T_USER}@${T_HOST}:${T_SRC}") != "" ]]; then
        {
            fusermount -u ${MOUNT_DIR}${T_DEST} &&
                echo " We have unmounted \
'${T_SRC}' mount from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}' \
successfully."
        } || {
            echo " Unmounting of \
'${T_SRC}' mount from host '${T_HOST}' \
with user '${T_USER}' on directory '${T_DEST}' \
has failed."
        }
    else
        echo " Share point not mounted. \
Unmounting not required."
    fi
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
}

mount() {
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    if [ ! -d ${INSTALL_DIR}${CONF_DIR} ]; then
        echo "(EE) Configuration directory not found."
        exit -1
    elif [ ! -f ${MOUNT_TARGETS} ]; then
        echo "(EE) Mount targets configuration file not found."
        exit -1
    elif [ ! -d ${MOUNT_DIR} ]; then
        echo "(EE) Mount root directory not found."
        exit -1
    else
        TARGETS=`egrep -v "^$|^#" ${INSTALL_DIR}${CONF_DIR}/${MOUNT_TARGETS}`
        for TARGET in ${TARGETS}; do
            effectiveMount ${TARGET} &
        done
    fi
    wait
    echo "Mounting sshfs network drives from host ${HOST} complete."
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
}

unmount() {
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    if [ ! -d ${INSTALL_DIR}${CONF_DIR} ]; then
        echo "(EE) Configuration directory not found."
        exit -1
    elif [ ! -f ${MOUNTARGETS} ]; then
        echo "(EE) Mount targets configuration file not found."
        exit -1
    elif [ ! -d ${MOUNT_DIR} ]; then
        echo "(EE) Mount root directory not found."
        exit -1
    else
        TARGETS=`egrep -v "^$|^#" ${INSTALL_DIR}${CONF_DIR}/${MOUNT_TARGETS}`
        for TARGET in ${TARGETS}; do
            effectiveUnmount ${TARGET} &
        done
    fi
    wait
    echo "========================================"
    echo "Network drives unmounting complete."
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
}

readConfig() {
    # Read configuration from file.
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # Original code was:
    ## Global settings
    ## TODO move to ini/conf file
    ## TODO put all params in the same file, targets and config?
    ## TODO pass configuration as cli parameter
    #INSTALL_DIR=/home/user/.local/bin/
    #CONF_DIR=../conf
    #MOUNT_TARGETS=sshfs-targets.conf
    #MOUNT_DIR=/home/user/Mount/sshfs/
    #HOST=Munin
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # If we had multiple instances of 'TARGET' in the configuration file
    # we would likely have to do something complicated like this:
    #while read LINE; do
    #    if [[ -n ${LINE} ]]; then
    #        RAW_VALUE="$(echo ${LINE} | egrep -v '^ *#|^$|^ *$')"
    #        if [ "${RAW_VALUE}" != "" ]; then
    #            TARGET_COUNTER=0
    #            if [ "$(echo ${RAW_VALUE} | grep ^TARGET)" != "" ]; then
    #                TARGET_${TARGET_COUNTER}=$(echo ${RAW_VALUE} | cut -d '=' -f 2)
    #                let TARGET_COUNTER+=1
    #            else
    #                $(echo ${RAW_VALUE} | cut -d '=' -f 1)=$(echo ${RAW_VALUE} | cut -d '=' -f 2)
    #            fi
    #        fi
    #    fi
    #done < ${1}
    # it's not even certain this code works.
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # The simple solution is to have a unique identifier for each target,
    # something like TARGET_id in the config file, and treat the targets
    # in a specific loop, then we can do a simple source of the configuration
    # file.
    echo "Sourcing ${1}"
    source ${1}
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # Check we have got the required parameters after sourcing the
    # configuration file.
    if [[ ${MOUNT_DIR} == "" ]]; then
        echo "Mount destination directory is missing"
    # Don't need the install dir.
    #elif [[ ${INSTALL_DIR} == "" ]]; then
    #    echo "Installation directory is missing"
    # Configuration file can be multi host
    #elif [[ ${HOST} == "" ]]; then
    #    echo "Server host name is missing"
    else
        echo "Targets mounting directory is ${MOUNT_DIR}"
    fi
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # Parse the targets.
    # How do you parse variables when you don't know their exact name?
    #for TARGET in ${TARGET_?}; do
    #    echo ${TARGET}
    #done
    # -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

}

main() {
    readConfig ${CONFIG_FILE}
}
################################################################################

################################################################################
# Main
main
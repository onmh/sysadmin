# Public IP getter

## Bash script to query online services which allow to determine public IP when on a local network and send notification via email when a change is detected.

### Requires bash 4 or higher for associative arrays

 `declare -a` call

 - current-value: store the currently recorded value in between script calls
 - get-public-ip.cron: cron call file
 - get-public-ip.sh: main code
 - public-ip.log: log of recorded values
 - resolv-routines.conf: list of web service calls to use to resolve public IP adress
 - setup.conf: setup parameters

A link to the executable script must be placed in a system path, such as `/usr/local/bin/`, in order for the cron call to work. If not, it must be modified to specify the full path.


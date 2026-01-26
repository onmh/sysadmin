#!/usr/bin/env bash
# Check if git repos below current directory are:
# - not up to date
# - have untracked files
# If none of these cases occur, nothing is reported.
curdir=$(pwd)
# Find all directories which are git repositories
for dir in $(find . -type d -name ".git" | sed 's/.git$//' | egrep -v "\.cache|\.config" ); do
    # go to directory and get the git status into the $res var
    res=$(cd $dir && git status)
    # Get the name of the local branch
    branch=$(echo -e "${res}" | grep "^On branch" | sed 's/^On branch //')
    # Get the status of the branch
    rep_sta=$(echo -e "${res}" | grep "^Your branch is" | sed 's/^Your branch is //')
    # If the branch is not up to this var will be empty
    uptod=$(echo -e "${res}" | grep "^Your branch is up to date" | sed 's/^Your branch is \(up to date\)/\1/')
    # If there are untracked files this variable will not be empty
    untracked=$(echo -e "${res}" | grep -A 2 "^Untracked files")
    #echo -e "${res}"
    if [ "${untracked}" != "" ]; then
      echo -e "# ===  Working on ${dir}  === #\nRepo is on branch ${branch}, status is ${rep_sta} and there are untracked files:\n${untracked}\n# ===  ---  === #"
    elif [ "${uptod}" == "" ]; then
      echo -e "# ===  Working on ${dir}  === #\nRepo is on branch ${branch} and it is not up to date: ${rep_sta}\n# ===  ---  === #"
    else
      echo -e "No untracked files for \"${dir}\" which is up to date and on branch \"${branch}\"\n# === --- === #"
    fi
    #cd $dir && git status;
    #cd $curdir
done

#!/usr/bin/env bash
# Check git status of all repos below current directory
curdir=$(pwd)
# Find all directories which are git repositories
for dir in $(find . -type d -name ".git" | sed 's/.git$//' | egrep -v "\.cache|\.config" ); do
    # go to directory and get the git status
    echo -e "\n ***** $dir *****\n" && cd $dir && git status && echo -e " ***** ----- *****\n" && cd $curdir
done

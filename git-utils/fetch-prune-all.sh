#!/usr/bin/env bash
curdir=$(pwd)
for dir in $(find . -type d -name ".git" | sed 's/.git$//' | egrep -v "\.cache|\.config" ); do
    echo "  === Working on ${dir} ===";
    cd $dir && git fetch --prune;
    echo "  === --- ==="
    cd $curdir
done

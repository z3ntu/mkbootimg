#!/bin/bash

prefix="$1"
shift

if [ -z "$prefix" ]; then
    echo "ERROR: provide prefix!"
    exit 1
fi

files=$(grep "write_.*_to_file" $(dirname "$0")/unpackbootimg.c | grep -v "void write_" | sed 's/.*write_\(\w\+\)_to_file("\(\w\+\)",.*/\1 \2/' | sort | uniq)

cmd="mkbootimg"

while IFS= read -r line; do
    arr=($line)
    argtype=${arr[0]}
    filename=${arr[1]}

    if [ ! -f $prefix$filename ]; then
        continue
    fi

    if [ "$argtype" == "string" ]; then
        cmd="$cmd --$filename \"$(cat $prefix$filename)\""
    elif [ "$argtype" == "buffer" ]; then
        cmd="$cmd --$filename $prefix$filename"
    else
        echo "ERROR: Unknown argtype $argtype!"
        exit 1
    fi
done <<< "$files"

cmd="$cmd $@"

eval $cmd

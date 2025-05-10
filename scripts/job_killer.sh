#!/bin/bash

# Init variables with default valuesname=""

VALID_ARGS=$(getopt -o n: --long name -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

# Parsing arguments
eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -n | --name)
        name=$2
        shift 2
        ;;
    --) shift;
        break
        ;;
  esac
done

# Check if the path variable is defined
# last_pid being optional, we don't check it
if [[ -z "name" ]]; then
  echo "You need to set the -n or --name option"
  exit 1
fi

# Process kill
last_pid=$(cat /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"$name"/last_pid)
kill $last_pid
killall chainner
killall python3.11
rm -rf ~/Documents/Mangas/manga_upscale/upscale_out/"$name"/launcher.lock
echo $?

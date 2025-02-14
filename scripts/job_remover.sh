#!/bin/bash

# Initialiser les variables par défaut
name=""

VALID_ARGS=$(getopt -o n: --long name -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

# Parse les options
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

# Vérifier que le chemin est défini
# last_pid étant optionnel, on ne le vérifie pas
if [[ -z "name" ]]; then
  echo "You need to set the -n or --name option"
  exit 1
fi

last_pid=$(cat /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"$name"/last_pid > /dev/null 2>&1)
kill $last_pid > /dev/null 2>&1
killall chainner > /dev/null 2>&1
killall python3.11 > /dev/null 2>&1
rm -rf ~/Documents/Mangas/manga_upscale/upscale_out/"$name"/ > /dev/null 2>&1

if [[ -d /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"$name"/ ]]; then
    echo 1
    exit 1
else
    echo 0
fi


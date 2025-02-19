#!/bin/bash

# Initialiser les variables par défaut
path=""

VALID_ARGS=$(getopt -o p: --long path: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

# Parse les options
eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -p | --path)
        path=$2
        shift 2
        ;;
    --) shift;
        break
        ;;
  esac
done

# Vérifier que le chemin est défini
# last_pid étant optionnel, on ne le vérifie pas
if [[ -z "$path" ]]; then
  echo "Vous devez fournir un chemin avec l'option --path ou -p."
  exit 1
fi

# Kill all previous process that may be still running
for pid in $(ps axf | grep upscale_esr_lib | grep -v grep | awk '{print $1}'); do
    kill -9 $pid
done

killall chainner > /dev/null 2>&1
killall python3.11 > /dev/null 2>&1

# Return pid
titleName=$(cut -d "/" -f7 <<< "$path")
touch /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"${titleName}"/launcher.lock > /dev/null 2>&1 &
/home/loicd/relax_tools/scripts/./upscale_esr_library_26012025.sh -p "$path" > /dev/null 2>&1 &
echo "$!"

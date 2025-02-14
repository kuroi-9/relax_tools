#!/bin/bash

while getopts ":p:" opt; do
  case $opt in
    p) # Option pour le chemin
      path=$OPTARG
      ;;
    \?) # Option invalide
      exit 1
      ;;
    :) # Option manquante
      exit 1
      ;;
  esac
done

dirname="$path"
dir_page_count=$(ls /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"$dirname" | wc -l)
dir_total_page_count=$(ls /home/loicd/Documents/Mangas/manga_upscale/to_upscale/"$dirname" | wc -l )
echo "$dirname|$dir_page_count|$dir_total_page_count" 


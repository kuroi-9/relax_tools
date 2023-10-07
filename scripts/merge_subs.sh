#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
NC='\033[0m'

#【MV】誇り高きアイドル／mona（CV：夏川椎菜）【HoneyWorks】

subsCount=$(ls subs_to_add/ | wc -l)
videosCount=$(ls destination_videos/ | wc -l)
generalCount=$2
renamed_subs_array=()
source_video_array=()
result_log_array=()

if [ "$videoCount" -ne "$subsCount" ];
then
	mkdir renamed_subs >/dev/null 2>&1

	echo "Vérification des sous-titres à ajouter"

	for video in source_videos/*;
	do
		mkvextract tracks "$video" "$1":renamed_subs/"$generalCount".ass >/dev/null 2>&1
		src_filename=$(basename "$video")
		src_extension=${filename##*.}
		src_basename="${filename%.*}"
		
		source_video_array+=($src_basename)
		
		if [ -f renamed_subs/"$generalCount".ass ];
		then
			renamed_subs_array+=("${GRAY}$src_basename -> subs : $sub${NC}")
		fi
		
		generalCount=$((generalCount+1))
	done

	generalCount=1

	for sub in subs_to_add/*;
	do
		cp "$sub" renamed_subs/"$generalCount".ass
		
		if [ -f renamed_subs/"$generalCount".ass ];
		then
			renamed_subs_array+=("${GRAY}${source_video_array[generalCount - 1]} -> subs : $sub${NC}")
		fi
		
		generalCount=$((generalCount+1))
	done

	for value in "${renamed_subs_array[@]}"
	do	
		echo -e $value
	done

	generalCount=1

	#####################################################

	echo "Vérifications des vidéos destination"

	for video in destination_videos/*;
	do
		echo -e "${renamed_subs_array[generalCount - 1]} -> $video"
		result_log_array+=("${renamed_subs_array[generalCount - 1]} -> $video")
	done

	#####################################################

	echo ----------------------------------
	echo "merge files ?"
	read -p ""

	clear
	display $result_log_array

	display() {
		for value in "${1[@]}"
		do	
			echo -e $value
		done
	}

	#####################################################

	for video in destination_videos/*;
	do
		mkvmerge -o "Épisode $generalCount".mkv renamed_subs/"$generalCount".ass "$video" >/dev/null 2>&1
		result_log_array[$generalCount - 1]="${GREEN}${result_log_array[$generalCount - 1]} \u2714"
		
		clear
		display $result_log_array
		generalCount=$((generalCount+1))
	done
fi

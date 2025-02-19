#!/bin/bash

for title_dir in /home/loicd/Documents/Mangas/manga_upscale/upscale_out/*
do
	for dir in "$title_dir"/*
	do
		dirname=${dir##*/}
		dir_page_count=$(ls "$dir" | wc -l)
		if [ -f /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"${title_dir##*/}"/"$dirname"/file_count ];
		then
			dir_total_page_count=$(cat /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"${title_dir##*/}"/"$dirname"/file_count)
		fi
		if [ -f "$title_dir"/last_pid ];
		then
			last_pid=$(cat "$title_dir"/last_pid)
		fi
		if [ -f /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"${title_dir##*/}"/"$dirname"/eta ];
		then
			eta=$(cat /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"${title_dir##*/}"/"$dirname"/eta)
		fi
		running=false
		completed=false

		ps -p $last_pid -o comm= > /dev/null 2>&1

		if [ $? -eq 0 -o -f "$title_dir"/launcher.lock ];
		then
			running=true
		fi
		if [ -f /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"${title_dir##*/}"/"$dirname"/completed.lock ];
		then
			completed=true
		fi

		if [ "$dirname" != "last_pid" -a "$dirname" != "launcher.lock" ];
		then
			echo "${title_dir##*/}|$dirname|$dir_page_count|$dir_total_page_count|$running|$completed|$eta"
		fi
	done
done

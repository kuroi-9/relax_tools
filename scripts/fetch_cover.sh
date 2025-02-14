#!/bin/bash

for dir in *; 
do
	files=("$dir"/*.cbz) > /dev/null 2>&1
	firstFile="${files[0]}" > /dev/null 2>&1
	
	echo --------------------
	echo "$dir"
	echo "$firstFile"
	
	mkdir temp_images
	unzip -o -d temp_images -j "$firstFile" > /dev/null 2>&1
	
	cd temp_images
	cover=$(find . \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | awk 'NR==2 {exit} 1')
	echo "$cover"
	ffmpeg -i "$cover" -vf scale=1080:-1 /home/loicd/Documents/Mangas/covers/"${dir// /_}_cover.jpg" -y > /dev/null 2>&1
	if [ -f /home/loicd/Documents/Mangas/covers/"${dir// /_}_cover.jpg" ];
	then
		echo OK
	fi
	echo --------------------
	
	cd ..
	rm -rf temp_images
done;

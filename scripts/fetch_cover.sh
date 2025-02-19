#!/bin/bash

for dir in *; 
do
	firstFile=$(ls -1v "$dir"/*.cbz | grep -P '\bv\d+\b' | head -n 1)

	if [ "$firstFile" == "" ]; then
		firstFile=$(ls -1v "$dir"/*.cbz | head -n 1)
	fi
	
	echo --------------------
	echo "$dir"
	echo "$firstFile"
	
	mkdir temp_images
	unzip -o -d temp_images -j "$firstFile" > /dev/null 2>&1
	
	cd temp_images
	cover=$(find . \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | ls -1v | awk 'NR==2 {exit} 1')
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

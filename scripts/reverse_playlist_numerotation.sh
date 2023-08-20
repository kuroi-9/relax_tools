#!/bin/bash

directory_size=$(ls | wc -l)
directory_size_old=$directory_size
global_count=1
global_reverse_count=$directory_size

mkdir reverse

echo "Il y a $directory_size chansons dans la playlist. [WORKING]"

#for song_number in $(seq $directory_size);
#do
#	if [ "$global_count" -ne "$song_number" ]
#	then
#		
#	fi
#	
#	song_id_seg=$(echo "$song_file" | cut -d '.' -f1)
#	echo $song_id_seg
#done

while [ $directory_size -gt 0 ];
do
	song_number=$global_count
	if [ "$song_number" -lt 10 ]
	then
		song_id="0$song_number"'. '
	else
		song_id="$song_number"'. '
	fi
	
	for song_file in "$song_id"*.flac;
	do
		song_test=$(echo "$song_file" | cut -d '-' -f2)
		
		if [ "$song_test" != "$song_id"*.flac ]
		then
			song_id_seg=$(echo "$song_file" | cut -d '.' -f1)
			song_name_seg=$(echo "$song_file" | cut -d '.' -f2)
			
			cp "$song_file" reverse/"$global_reverse_count."''"$song_name_seg.flac"
		else
			directory_size=$((directory_size+1))
		fi
		
		global_reverse_count=$((global_reverse_count-1))
	done
	
	global_count=$((global_count+1))
	directory_size=$((directory_size-1))
done

global_count=0
mkdir final

for song_number in $(seq $global_reverse_count $directory_size_old);
do
	song_id="$song_number"'. '
	
	#echo $song_id
	
	for song_file in reverse/"$song_id"*.flac;
	do
		song_id_seg=$(echo "$song_file" | cut -d '.' -f1)
		song_name_seg=$(echo "$song_file" | cut -d '.' -f2)
		
		global_reverse_count_offset=$((global_reverse_count+10))
			
		if [[ "$song_number" -lt "$global_reverse_count_offset" ]]
		then
			cp "$song_file" final/"0$global_count."''"$song_name_seg.flac"
		else
			cp "$song_file" final/"$global_count."''"$song_name_seg.flac"
		fi
		
		global_count=$((global_count+1))
	done
done

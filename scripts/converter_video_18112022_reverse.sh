#!/bin/bash

current_dir_path=${PWD##*/}          
current_dir_name=${current_dir_path:-/}
i=1
intensity=$2
divider=2

var1=3
var2=4

divided=$(echo "scale=2 ; $2 / $divider" | bc)

if [ "$1" != "anime" ] && [ "$1" != "library" ] && [ "$1" != "folder"  ]
then
	echo "Usage : <anime/library/folder> <intensity> (if anime)<audio format> <audio canals>"
else
	if [ "$1" = "anime" ]
	then
		for corrected_file in corrected*;
		do
			rm "$corrected_file"
		done
		
		echo "------------------ANIME------------------"
		echo "$current_dir_name"
		echo "Intensité appliquée : $2"
		echo "Entrez le numéro de l'épisode à convertir : " 
		read numero_episode							# number of the episode the program need to find
		for file in *.mkv;
		do
			if [ $i -eq "$numero_episode" ]
			then
				echo "Est-ce le bon fichier [Enter]?"
				echo "$file"
				read -p ""
				ffmpeg -i "$file" -vn -acodec copy output-audio"$3" -y
				if [ "$4" -eq 2 ]
				then
					ffmpeg -i output-audio"$3" stereo-audio.flac -y

					#ffmpeg -i stereo-audio.flac -map_channel 0.0.0 left.flac -map_channel 0.0.1 right.flac -y > /dev/null 2>&1;
					#ffmpeg -i right.flac -af crystalizer=i=-1.23 righte.flac -y > /dev/null 2>&1; # Baisser un peu, vers 27-28
					#ffmpeg -i righte.flac -filter:a "volume=-0.2dB" rightee.flac -y > /dev/null 2>&1; # Laisser mais pas indispensable
					#ffmpeg -i right.flac -af "adynamicsmooth=sensitivity=999999:basefreq=100" righte.flac -y > /dev/null 2>&1; # Augmenter un peu basefreq
					#ffmpeg -i left.flac -filter:a "volume=-1dB" lefte.flac -y
					#ffmpeg -i left.flac -af acontrast=0.02 lefte.flac -y
					#ffmpeg -i left.flac -i righte.flac -filter_complex "[0:a][1:a]amerge" corrected-audio.flac -y > /dev/null 2>&1;
					ffmpeg -i stereo-audio.flac -af "crossfeed=strength=0.3:range=1:slope=0.5:level_in=0.9:level_out=1" mied.flac -y
					ffmpeg -i mied.flac -af "adelay=0|0.12" corrected-audio.flac -y
				else
					ffmpeg -i output-audio"$3" -c dca -strict -2 -vol 425 -af "pan=stereo|c0=0.5*c2+0.707*c0+0.707*c4+0.5*c3|c1=0.5*c2+0.707*c1+0.707*c5+0.5*c3" stereo-audio"$3" -y
					ffmpeg -i stereo-audio"$3" stereo-audio.flac -y

					ffmpeg -i stereo-audio.flac -map_channel 0.0.0 left.flac -map_channel 0.0.1 right.flac -y
					ffmpeg -i right.flac -af crystalizer=i=-"$2" righte.flac -y
					ffmpeg -i left.flac -i righte.flac -filter_complex "[0:a][1:a]amerge" corrected-audio.flac -y
					
					# Below version was an attemp to fully keep 5.1.
					# The center channel make it difficult, because it's dialogue on a mono channel.

					#ffmpeg -i output-audio"$3" output-audioo.flac -y
					#ffmpeg -i output-audioo.flac -filter_complex "channelsplit=channel_layout=5.1[FL][FR][FC][LFE][BL][BR]" -map "[FL]" front_left.flac -map "[FR]" front_right.flac -map "[FC]" front_center.flac -map "[LFE]" lfe.flac -map "[BL]" back_left.flac -map "[BR]" back_right.flac -y
					#ffmpeg -i front_right.flac -af crystalizer=i=-"$2" front_righte.flac -y
					#ffmpeg -i front_center.flac -ac 2 front_centers.flac
					#ffmpeg -i front_centers.flac -map_channel 0.0.0 l.flac -map_channel 0.0.1 r.flac -y
					#ffmpeg -i r.flac -af crystalizer=i=-"$2" righte.flac -y
					#ffmpeg -i l.flac -i righte.flac -filter_complex "[0:a][1:a]amerge" front_centere.flac -y
					#ffmpeg -i back_right.flac -af crystalizer=i=-"$2" back_righte.flac -y
					#ffmpeg -i lfe.flac -af crystalizer=i=-"$2" lfee.flac -y

					#LFE 2 CHANNELS
					#ffmpeg -i lfe"$3" lfef.flac -y
					#ffmpeg -i lfef.flac -map_channel 0.0.0 left.flac -map_channel 0.0.1 right.flac -y
					#ffmpeg -i right.flac -af crystalizer=i=-"$2" righte.flac -y
					#ffmpeg -i left.flac -i righte.flac -filter_complex "[0:a][1:a]amerge" lfee.flac -y

					#ffmpeg -i l.flac -i righte.flac -i lfee.flac -i back_left.flac -i back_righte.flac -filter_complex "[0:a][1:a][2:a][3:a][4:a]amerge=inputs=5[a]" -map "[a]" corrected-audio.flac -y
				fi

				ffmpeg -i "$file" -i corrected-audio.flac -map 0 -map 1 -c copy output.mkv -y
				ffmpeg -i output.mkv -map 0 -map -0:a:0 -c copy "corrected - $file" -y

				rm left"$3"
				rm righte"$3"
				rm right"$3"
				rm output.mkv
					
				mpv --fs "corrected - $file"		# launching mpv with the modified file
					
				rm output-audio"$3"
				rm stereo-audio"$3"
				rm corrected-audio"$3"				# clearing folder (extra created files)
			fi
				
			i=$((i+1))
		done
		
		
	fi
	
	if [ "$1" = "library" ]
	then
		echo "------------------MUSIC LIBRARY------------------"
		read -p "Conversion de bibliothèque en .flac - $2"
		for directory in *;
		do
			mkdir /run/user/1000/gvfs/mtp:host=Google_Pixel_6_1C211FDF6004JP/"Espace de stockage interne partagé"/Music/converted_cinqcinq/"$directory"
			for file in "$directory"/*.flac;  
			do
				ffmpeg -i "$file" -map_channel 0.0.0 left.flac -map_channel 0.0.1 right.flac -y
				ffmpeg -i right.flac -af crystalizer=i=-$2 righte.flac -y
				ffmpeg -i left.flac -i righte.flac -filter_complex "[0:a][1:a]amerge" /run/user/1000/gvfs/mtp:host=Google_Pixel_6_1C211FDF6004JP/"Espace de stockage interne partagé"/Music/converted_cinqcinq/"$file" -y

				rm left.flac
				rm righte.flac
				rm right.flac
			done	
		done
	fi
	
	if [ "$1" = "folder" ]
	then
		echo "------------------MUSIC FOLDER------------------"
		read -p "Conversion de dossier simple en .flac - $2"
			mkdir ~/Musique/convertedP/"$current_dir_name"
			for file in *.flac;  
			do
				ffmpeg -i "$file" -map_channel 0.0.1 -map_channel 0.0.0 fuierfh.flac -y
				ffmpeg -i fuierfh.flac -map_channel 0.0.0 left.flac -map_channel 0.0.1 right.flac -y
				ffmpeg -i right.flac - af crystalizer=i=-$2 righte.flac -y
				ffmpeg -i left.flac -i righte.flac -filter_complex "[0:a][1:a]amerge" ~/Musique/convertedP/"$current_dir_name"/"$file" -y

				rm left.flac
				rm righte.flac
				rm right.flac
			done	

	fi
fi

#end of file

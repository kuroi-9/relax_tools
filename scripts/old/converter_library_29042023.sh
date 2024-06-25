#!/bin/bash

current_dir_path=${PWD##*/}          
current_dir_name=${current_dir_path:-/}
i=1

tab=()
tabb=()

albumCount=$(ls | wc -l)

analyse(){
	cuted_dir=$(echo $1 | cut -d '/' -f8)
	cd "$1" > /dev/null 2>&1;
	current_dir_check=$(pwd)
	current_dir_check_name=$(echo "$current_dir_check" | cut -d '/' -f8)

	echo "$cuted_dir"
	if [[ "$current_dir_check_name" = "$cuted_dir" ]]
	then
		echo "Folder listing :"
		ls -l "$1"
		echo "-------------------------------------------------------------------------------------------------------------"
		for something in *;  
		do	
			if [ -d "$something" ]
			then
				echo "jump in $something"
				analyse "$something"
			elif [ -f "$something" ]
			then
				cuted_something=$(echo $something | cut -d '/' -f13)
				mkdir ~/Musique/test_a/"$cuted_dir" > /dev/null 2>&1;
				
				
				echo "[WORKING] converting $something ..."
				#ffmpeg -i "$something" -map_channel 0.0.0 left.flac -map_channel 0.0.1 right.flac -y > /dev/null 2>&1;
				#ffmpeg -i right.flac -af crystalizer=i=-1.23 righte.flac -y > /dev/null 2>&1; # Baisser un peu, vers 27-28
				#ffmpeg -i left.flac -af crystalizer=i=-0.2 lefte.flac -y > /dev/null 2>&1; # Baisser un peu, vers 27-28
				#ffmpeg -i right.flac -af "adynamicsmooth=sensitivity=999999:basefreq=100" righte.flac -y > /dev/null 2>&1;# Augmenter un peu basefreq	
				#ffmpeg -i right.flac -filter:a loudnorm=i=-24:tp=-2:lra=7 righte.flac
				#ffmpeg -i left.flac -filter:a "volume=-1dB" lefte.flac -y > /dev/null 2>&1;
				#ffmpeg -i left.flac -af acontrast=0.02 lefte.flac -y
				#ffmpeg -i "$something" -map_channel 0.0.1 -map_channel 0.0.0 ~/Musique/despair/"$1"/"$something" -y > /dev/null 2>&1;
				#ffmpeg -i left.flac -i righte.flac -filter_complex "[0:a][1:a]amerge" ~/Musique/despair/"$1"/"$something" -y > /dev/null 2>&1;
				#ffmpeg -i "$something" -af "adelay=0|0.12" ~/Musique/test_a/"$1"/"$something" -y > /dev/null 2>&1;
				ffmpeg -i "$something" -af 'bs2b=profile=jmeier' ~/Musique/test_a/"$cuted_dir"/"$cuted_something" -y > /dev/null 2>&1;
				
				rm left.flac > /dev/null 2>&1;
				rm righte.flac > /dev/null 2>&1;
				rm right.flac > /dev/null 2>&1;
				rm lefte.flac > /dev/null 2>&1;
				rm mied.flac > /dev/null 2>&1;
			else
				echo "[ERROR] $something"
				echo "$something" >> errors
			fi
		done
		cd ../
	else
		echo "An error occured, please correct it manually with mv"
		echo "[ERROR] $cuted_dir"
		echo "$cuted_dir" >> errors
		read
		analyse "$1"
	fi
}


echo "$current_dir_path"
line=""
rm errors > /dev/null 2>&1;
touch errors
cp "qobuz_titres.m3u" ~/Musique/test_a/

for directory in $(find "." -type d -printf '"%T+\t%p\n"' | sort | cut -d '/' -f2 | sed 's/^/\//' |  sed 's/$/#/' | tail -n +2);
do
	#clear
	#echo "------- $i sur $albumCount -----------------------------------------------------------------------------------------------------"
	
	if [[ "$directory" = *"#"* ]];
	then
		line=$line$directory
		final_line=$(echo $line | cut -d '#' -f1)
		tab+=("$final_line")
		line=""
	else
		line=$line$directory" "
	fi
	#analyse "$(pwd)/$directory"
	#i=$((i+1))
done

for directory in "${tab[@]}";
do
	clear
	echo "------- ERRORS -----------------------------------------------------------------------------------------------------------------"
	cat errors
	echo "------- $i sur $albumCount -----------------------------------------------------------------------------------------------------"
	analyse "$(pwd)$directory"
	i=$((i+1))
done


#shutdown

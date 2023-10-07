#!/bin/bash

current_dir_path=${PWD##*/}          
current_dir_name=${current_dir_path:-/}
i=1

albumCount=$(ls | wc -l)

analyse(){
	cd "$1"
	#pwd
	echo "Folder listing :"
	ls -l
	echo "-----------------------------------------------------------------------------------------------"
	for something in *;  
	do	
		if [ -d "$something" ]
		then
			echo "jump in $something"
			analyse "$something"
		else
			mkdir ~/Musique/test_a/"$1" > /dev/null 2>&1;
			
			filename=$(basename "$something")
			extension=${filename##*.}
			basename="${filename%.*}"
			echo "[WORKING COMPRESSION] converting $something ..."
			
			#oggenc "$something" --bitrate 320 -o ~/Musique/test_a/"$1"/"$something" > /dev/null 2>&1;
			##mkdir "~/Musique/test_a/$1/"  > /dev/null 2>&1;
			#ffmpeg -i "$something" ~/Musique/test_a/"$1"/"$something".mp3
			#eyeD3 --write-images="/home/loicd/Musique/test_a/$1" "/home/loicd/Musique/test_a/$1/$something.mp3"
			
			##ulimit -s 65536  > /dev/null 2>&1;
			##ffmpeg -i "$something" -map 0:1 "/home/loicd/Musique/test_a/$1/FRONT_COVER.jpg" -y > /dev/null 2>&1;
			##ogg-image-blobber.sh "/home/loicd/Musique/test_a/$1/FRONT_COVER.jpg" > /dev/null 2>&1;
			#touch "/home/loicd/Musique/test_a/$1/metadata.dat"
			#echo ";FFMETADATA1" > "/home/loicd/Musique/test_a/$1/metadata.dat"
			#echo "METADATA_BLOCK_PICTURE=`cat /home/loicd/Musique/test_a/"$1"/FRONT_COVER.base64`" >> "/home/loicd/Musique/test_a/$1/metadata.dat"
			
			#DESC=`basename "/home/loicd/Musique/test_a/$1/FRONT_COVER.jpeg"`
			#APIC=`base64 --wrap=0 "/home/loicd/Musique/test_a/$1/FRONT_COVER.jpeg"`
			#MIME="image/jpg"
			#ffmpeg -i "/home/loicd/Musique/test_a/$1/FRONT_COVER.png" "/home/loicd/Musique/test_a/$1/FRONT_COVER_2.jpg"
			##oggenc "$something" -q 8 -o ~/Musique/test_a/"$1"/"$basename".ogg > /dev/null 2>&1;
			
			#vorbiscomment -l ~/Musique/test_a/"$1"/"$basename".ogg | grep -v '^album=' | grep -v '^genre=' | grep -v '^artist=' > ~/Musique/test_a/"$1"/"temp_$something".ogg.tags
			#echo "METADATA_BLOCK_PICTURE=`cat /home/loicd/Musique/test_a/"$1"/FRONT_COVER.base64`" >> /home/loicd/Musique/test_a/"$1"/"temp_$something".ogg.tags
			
			#ffmpeg -i ~/Musique/test_a/"$1"/"temp_$something".ogg -i "/home/loicd/Musique/test_a/$1/metadata.dat" -map_metadata 1 -codec copy ~/Musique/test_a/"$1"/"$basename".ogg


			#vorbiscomment -w -R -c ~/Musique/test_a/"$1"/"temp_$something".ogg.tags ~/Musique/test_a/"$1"/"$basename".ogg

			ffmpeg -i "$something" -map_channel 0.0.0 left.flac -map_channel 0.0.1 right.flac -y > /dev/null 2>&1;
			ffmpeg -i left.flac -af "acompressor=mode=upward:threshold=1:ratio=4:1:attack=3:release=350:knee=4" 

			
			rm "/home/loicd/Musique/test_a/$1/FRONT_COVER.jpg" > /dev/null 2>&1;
			rm "/home/loicd/Musique/test_a/$1/FRONT_COVER.base64" > /dev/null 2>&1;
			#rm "/home/loicd/Musique/test_a/$1/metadata.dat"
			rm "/home/loicd/Musique/test_a/$1/temp_$something.ogg.tags" > /dev/null 2>&1;
			

			
			#echo METADATA_BLOCK_PICTURE="$APIC" > ~/Musique/test_a/"$1"/"temp_$something".ogg.tags2
			#vorbiscomment -w -R -c ~/Musique/test_a/"$1"/"temp_$something".ogg.tags2 ~/Musique/test_a/"$1"/"temp_$something".ogg
			#vorbiscomment -a -R -t COVERARTDESCRIPTION="$DESC" ~/Musique/test_a/"$1"/"temp_$something".ogg
			#vorbiscomment -a -R -t COVERARTMIME="$MIME" ~/Musique/test_a/"$1"/"temp_$something".ogg
			#vorbiscomment -a -R -c ~/Musique/test_a/"$1"/"temp_$something".ogg.tags ~/Musique/test_a/"$1"/"temp_$something".ogg

			#oggart.sh "/home/loicd/Musique/test_a/$1/temp_$something.ogg" "/home/loicd/Musique/test_a/$1/FRONT_COVER_2.jpg" -e
			#id3v2 --ti "/home/loicd/Musique/test_a/$1/FRONT_COVER.png" "/home/loicd//Musique/test_a/$1/temp_$something.ogg"
			#ffmpeg -i ~/Musique/test_a/"$1"/"temp_$something".ogg -i "/home/loicd/Musique/test_a/$1/FRONT_COVER.png" -map_metadata 0 -map 0 -map 1 -acodec copy ~/Musique/test_a/"$1"/"$something".ogg
			#metaflac --import-picture-from="/home/loicd/Musique/test_a/$1/FRONT_COVER.png" ~/Musique/test_a/"$1"/"f_$something"


			#ffmpeg -i right.flac -af "equalizer=f=4550:t=h:w=1134:g=-2,equalizer=f=4900:t=h:w=1134:g=-1,equalizer=f=18058:t=h:w=4142:g=-1.42" righte.flac -y > /dev/null 2>&1;
			
			#fmpeg -i "$something" -af "equalizer=f=20:t=h:w=4.6:g=-4:c=0,equalizer=f=24:t=h:w=5.5:g=-1.5:c=0,equalizer=f=27:t=h:w=6.1:g=-3:c=0,equalizer=f=36.5:t=h:w=8.4:g=-2:c=0,equalizer=f=460:t=h:w=105:g=-0.5:c=0,equalizer=f=571:t=h:w=131:g=-1:c=0,equalizer=f=709:t=h:w=162:g=-1:c=0,equalizer=f=879:t=h:w=201:g=-0.85:c=0,equalizer=f=1091:t=h:w=250:g=-0.6:c=0,equalizer=f=1354:t=h:w=311:g=-0.45:c=0,equalizer=f=3200:t=h:w=737:g=-0.95:c=0,equalizer=f=4000:t=h:w=914:g=-0.95:c=0,equalizer=f=5650:t=h:w=914:g=-1:c=0,equalizer=f=9400:t=h:w=2167:g=-1:c=0,equalizer=f=10400:t=h:w=2167:g=-1.7:c=0,equalizer=f=11727:t=h:w=2690:g=-3:c=0,equalizer=f=13000:t=h:w=2690:g=-2:c=0,equalizer=f=4550:t=h:w=1134:g=-2:c=1,equalizer=f=4900:t=h:w=1134:g=-1:c=1,equalizer=f=18058:t=h:w=4142:g=-1.42:c=1" ~/Musique/test_a/"$1"/"$something" -y > /dev/null 2>&1;
			
			
			
			#ffmpeg -i left.flac -af "firequalizer=gain_entry='entry(20,-4); entry(24, -1.5); entry(27, -3); entry(36, -2); entry(500, -1.1); entry(600, -1.1); entry(700, -0.75); entry(800, -0.5); entry(900, -0.4); entry(3000, -1); entry(4000, -1); entry(10000, -1); entry(12000, -3); entry(13000, -2); entry(18000, -1)'" lefte.flac
			#ffmpeg -i right.flac -af crystalizer=i=-1.23 righte.flac -y > /dev/null 2>&1; # Baisser un peu, vers 27-28
			#ffmpeg -i left.flac -af crystalizer=i=-0.2 lefte.flac -y > /dev/null 2>&1; # Baisser un peu, vers 27-28
			#ffmpeg -i left.flac -af "adynamicsmooth=sensitivity=999999:basefreq=2" lefte.flac -y > /dev/null 2>&1;	
			#ffmpeg -i left.flac -af "highpass=f=100" lefte.flac -y
			
			#ffmpeg -i right.flac -filter:a loudnorm=i=-24:tp=-2:lra=7 righte.flac
			#ffmpeg -i left.flac -filter:a "volume=-1dB" lefte.flac -y > /dev/null 2>&1;
			#ffmpeg -i left.flac -af acontrast=0.02 lefte.flac -y
			#ffmpeg -i "$something" -map_channel 0.0.1 -map_channel 0.0.0 ~/Musique/despair/"$1"/"$something" -y > /dev/null 2>&1;
			
			#ffmpeg -i lefte.flac -i right.flac -filter_complex "[0:a][1:a]amerge" ~/Musique/test_a/"$1"/"$something" -y > /dev/null 2>&1;
			#ffmpeg -i miede.flac -af "stereotools=balance_out=0.1" ~/Musique/test_a/"$1"/"$something" -y > /dev/null 2>&1;
			#ffmpeg -i mied.flac é-af "adelay=0|0|0.05" ~/Musique/test_a/"$1"/"$something" -y > /dev/null 2>&1;
			#ffmpeg -i mied.flac -af 'bs2b=profile=jmeier' ~/Musique/test_a/"$1"/"$something" -y > /dev/null 2>&1;
			
			#--af=lavfi="[crossfeed=strength=0.3:range=1:slope=0.5:level_in=0.9:level_out=1]",lavfi="[adelay=0|0.05]"
			#ffmpeg -i "$something" -af "adelay=0|0.12" mied.flac -y > /dev/null 2>&1;
			#ffmpeg -i "$something" -af "crossfeed" ~/Musique/test_a/"$1"/"$something" -y > /dev/null 2>&1;
			#ffmpeg -i "$something" -af acontrast=100 ~/Musique/test_a/"$1"/"$something" -y > /dev/null 2>&1;
			
			rm left.flac > /dev/null 2>&1;
			rm righte.flac > /dev/null 2>&1;
			rm right.flac > /dev/null 2>&1;
			rm lefte.flac > /dev/null 2>&1;
			rm mied.flac > /dev/null 2>&1;
			rm miede.flac > /dev/null 2>&1;
			rm ~/Musique/test_a/"$1"/miede.flac > /dev/null 2>&1;
		fi
	done
	cd ../
}

echo "$current_dir_path"
mv "qobuz_titres.m3u" ~/Musique/test_a/
prlimit --pid=$$ -s 65536

for directory in *
do
	clear																									 
	echo "------- $i sur $albumCount ------------------------------------------------------------------------"
	echo "v3.1 | $directory"
	analyse "$directory"
	i=$((i+1))
done

#shutdown

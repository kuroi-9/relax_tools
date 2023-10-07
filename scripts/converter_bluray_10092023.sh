#!/bin/bash

#$1 is path
#$2 is audio format (PCM out so DTS not useful and using it make tsmuxer getting stuck)
#$3 is channel number (2.0 => 2 or 5.1 => <other than 2>)
#$4 is the video stream ID
#$5 is the audio stream ID
#$6 is muxing lang
#$7 is audio track number (TEMP)
#$8 is subs track number  (TEMP)

#$9 is "renamed subs" path (without END slash)



playlist=()
global_count=0
global_offset=0

renamed_subs_path=""
sub_offset=1

mpls_playlist=()
m2ts_playlist=()
mpls_lengths_playlist=()

convert_m2ts_to_mkv_and_correct() {
	current_mpls_playlist_of_m2ts=$1
	for current_m2ts in ${current_mpls_playlist_of_m2ts[@]};
	do
		# convert the m2ts in .mkv to modify its data with converter_video.sh
		current_m2ts_number="${current_m2ts%.*}" > /dev/null 2>&1;
		echo CONVERSION $current_m2ts_number.m2ts
		mkvmerge "$current_m2ts" -o "$current_m2ts_number".mkv > /dev/null 2>&1;
		# TODO make prompt for tracks number to extract (subs for example)
		mkvextract "$current_m2ts_number".mkv tracks $7:current_mkv_audio.wav
		
		if [ "$8" != "n" ];
		then
			mkvextract "$current_m2ts_number".mkv tracks $8:current_mkv_subs.sup
		else
			#TODO to test
			mkvextract "$9/$sub_offset".ass -o current_mkv_subs.sup
		fi
		
		# default values for encoding
		m2ts_audio_codec="pcm_s24le"
		m2ts_audio_format=".wav"
		
		# optional user choice
		if [ "$2" = "PCM_16" ]
		then
			m2ts_audio_codec="pcm_s16le"
			m2ts_audio_format=".wav"
		fi
		if [ "$2" = "PCM_24" ]
		then
			m2ts_audio_codec="pcm_s24le"
			m2ts_audio_format=".wav"
		fi
		#TODO: support for DTS series
		if [ "$2" = "DTS" ]
		then
			m2ts_audio_codec="pcm_s16le"
			m2ts_audio_format=".wav"
		fi
		if [ "$2" = "DTS_HD" ]
		then
			m2ts_audio_codec="pcm_s24le"
			m2ts_audio_format=".wav"
		fi
		
		# correcting step
		# ffmpeg -i "$current_m2ts_number".mkv -acodec "$m2ts_audio_codec" current_mkv_audio"$m2ts_audio_format" -y > /dev/null 2>&1;
		if [ "$4" = "2" ]
		then
			ffmpeg -i current_mkv_audio"$m2ts_audio_format" current_mkv_audio_stereo.flac -y
			#ffmpeg -i current_mkv_audio_stereo.flac -af "adelay=0|0.12" current_mkv_audio_stereo_corrected.flac -y > /dev/null 2>&1;
			ffmpeg -i current_mkv_audio_stereo.flac -af "crossfeed" current_mkv_audio_stereo_corrected.flac -y > /dev/null 2>&1;
		else
			ffmpeg -i current_mkv_audio"$m2ts_audio_format" -c dca -strict -2 -af "pan=stereo|c0=0.5*c2+0.707*c0+0.707*c4+0.5*c3|c1=0.5*c2+0.707*c1+0.707*c5+0.5*c3" current_mkv_audio_stereo"$m2ts_audio_format" -y > /dev/null 2>&1;
			ffmpeg -i current_mkv_audio_stereo"$m2ts_audio_format" current_mkv_audio_stereo.flac -y > /dev/null 2>&1;
			#ffmpeg -i current_mkv_audio_stereo.flac -af "adelay=0|0.12" current_mkv_audio_stereo_corrected.flac -y > /dev/null 2>&1;
			ffmpeg -i current_mkv_audio_stereo.flac -af "crossfeed" current_mkv_audio_stereo_corrected.flac -y > /dev/null 2>&1;
		fi
		
		ffmpeg -i current_mkv_audio_stereo_corrected.flac -acodec "$m2ts_audio_codec" current_mkv_audio_stereo_corrected"$m2ts_audio_format" -y > /dev/null 2>&1;
		mv current_mkv_audio_stereo_corrected"$m2ts_audio_format" ../STREAM/"$current_m2ts_number"_corrected_lang"$m2ts_audio_format" > /dev/null 2>&1;
		mv current_mkv_subs.sup ../STREAM/"$current_m2ts_number"_mkv_subs.sup > /dev/null 2>&1;
		# ffmpeg -i "$current_m2ts_number"_corrected.mkv -map 0 -map -0:a:0 -c copy "$current_m2ts_number"_corrected_lang.mkv -y > /dev/null 2>&1;
		
		rm current_mkv_audio"$m2ts_audio_format" > /dev/null 2>&1;
		rm current_mkv_audio_stereo.wav > /dev/null 2>&1;
		rm current_mkv_audio_stereo.flac > /dev/null 2>&1;
		rm current_mkv_audio_stereo_corrected.flac > /dev/null 2>&1;
		# rm current_mkv_audio_stereo_corrected"$m2ts_audio_format"
		# rm "$current_m2ts_number"_corrected.mkv
		
		sub_offset=$((sub_offset + 1))
	done
}
	
mux_mkv_to_m2ts() {
	current_mpls_playlist_of_m2ts=$1
	current_mpls=${mpls_playlist[$3]}
	current_mpls_number="${current_mpls%.*}"
	first_m2ts_element_of_given_array="${current_mpls_playlist_of_m2ts[0]}"
	first_m2ts_element_of_given_array_without_path=$(echo $first_m2ts_element_of_given_array | sed 's/^.\{10\}//')
	current_m2ts_number="${first_m2ts_element_of_given_array_without_path%.*}"
	echo $current_m2ts_number
	current_m2ts_number_no_leading_zeros=$(expr $current_m2ts_number + 0)
	current_mpls_number_no_leading_zeros=$(expr $current_mpls_number + 0)
	touch meta
	echo 'MUXOPT --no-pcr-on-video-pid --new-audio-pes --blu-ray --vbr --mplsOffset='"$current_mpls_number_no_leading_zeros"' --m2tsOffset='"$current_m2ts_number_no_leading_zeros"' --custom-chapters= --vbv-len=500 --start-time=27000000' > meta
	
	line="$4"', ' 
	for m2ts_of_current_mpls_playlist in ${current_mpls_playlist_of_m2ts[@]};
	do
		current_m2ts_number="${m2ts_of_current_mpls_playlist%.*}"
		line+='"'$(pwd)'/'"$current_m2ts_number"'.mkv"'
		
		if [ "$m2ts_of_current_mpls_playlist" != "${current_mpls_playlist_of_m2ts[-1]}" ]
		then
			line+='+'
		fi
	done
	line+=', track=1, lang=und'
	echo $line >> meta
	
	line="$5"', '
	for m2ts_of_current_mpls_playlist in ${current_mpls_playlist_of_m2ts[@]};
	do
		current_m2ts_number="${m2ts_of_current_mpls_playlist%.*}"
		line+='"'$(pwd)'/'"$current_m2ts_number"'_corrected_lang'"$m2ts_audio_format"'"'
		
		if [ "$m2ts_of_current_mpls_playlist" != "${current_mpls_playlist_of_m2ts[-1]}" ]
		then
			line+='+'
		fi
	done
	line+=', track=2, lang='"$6"
	echo $line >> meta
	
	if [ "$8" != "n" ];
	then
		line="S_HDMV/PGS"', '
		for m2ts_of_current_mpls_playlist in ${current_mpls_playlist_of_m2ts[@]};
		do
			current_m2ts_number="${m2ts_of_current_mpls_playlist%.*}"
			# TODO
			line+='"'$(pwd)'/'"$current_m2ts_number"_mkv_subs.sup'"'
			
			if [ "$m2ts_of_current_mpls_playlist" != "${current_mpls_playlist_of_m2ts[-1]}" ]
			then
				line+='+'
			fi
		done
		line+=', fps=23.976, track=3, lang=fra'
		echo $line >> meta
	fi
	
	mkdir "$current_mpls_number"_mux_output
	tsmuxer meta "$current_mpls_number"_mux_output

	# move produced files in the final testing folder
	#TODO: mv files (prio2)
	mv -f "$current_mpls_number"_mux_output/BDMV/PLAYLIST/*.mpls MPLS_OUTPUT > /dev/null 2>&1;
	mv -f "$current_mpls_number"_mux_output/BDMV/STREAM/*.m2ts M2TS_OUTPUT > /dev/null 2>&1;
	mv -f "$current_mpls_number"_mux_output/BDMV/CLIPINF/*.clpi CLIPINF_OUTPUT > /dev/null 2>&1;

	rm -r "$current_mpls_number"_mux_output > /dev/null 2>&1;
	rm ../STREAM/"$current_m2ts_number".mkv > /dev/null 2>&1;
	rm ../STREAM/"$current_m2ts_number"_corrected_lang"$m2ts_audio_format" > /dev/null 2>&1;
	rm ../STREAM/"$current_m2ts_number"_mkv_subs.sup > /dev/null 2>&1;
}

mkdir MPLS_OUTPUT
mkdir M2TS_OUTPUT
mkdir CLIPINF_OUTPUT

read "'renamed_subs' path (WITHOUT the END slash) :" renamed_subs_path

# MAIN
for current_mpls in *.mpls;
do
	REPLY="init"
	current_mpls_length=0
	
	echo "List of .m2ts linked to $current_mpls (tsmuxer order, exclude menus and play_all)"
	while [ "$REPLY" != "" ]
	do
  		read 
  		if [ "$REPLY" != "" ]
  		then
  			m2ts_playlist+=($REPLY.m2ts)
  			current_mpls_length=$((current_mpls_length+1))
  		fi
  	done
	
	if [ $current_mpls_length -ne 0 ]
	then
		mpls_playlist+=($current_mpls)
		mpls_lengths_playlist+=($current_mpls_length)
	fi
done

m2ts_count=0
current_mpls_playlist_of_m2ts=()
for mt2s_in_mpls_playlist in ${m2ts_playlist[@]};
do
	if [ "$m2ts_count" -lt "${mpls_lengths_playlist[$global_count]}" ]
	then
		echo "$mt2s_in_mpls_playlist in ${mpls_playlist[$global_count]}"
		mt2s_in_mpls_playlist_length=$(ffprobe -i "../STREAM/$mt2s_in_mpls_playlist" -show_entries format=duration -v quiet -of csv="p=0")
		
		if (( $(echo "$mt2s_in_mpls_playlist_length <= 300.0" | bc -l) ));
		then
			echo "$mt2s_in_mpls_playlist" VIDEO LENGTH WARNING
		fi
		
		current_mpls_playlist_of_m2ts+=("../STREAM/$mt2s_in_mpls_playlist")
		m2ts_count=$((m2ts_count+1))
	else
		# convert and correct
		convert_m2ts_to_mkv_and_correct $current_mpls_playlist_of_m2ts $2 $3 $4 $5 $6 $7 $8 $
		# mux converted bracket
		echo MUXING START ${mpls_playlist[$global_count]}
		mux_mkv_to_m2ts $current_mpls_playlist_of_m2ts $global_offset $global_count $4 $5 $6
		# delete source bracket files
		echo move on
		echo '-------------------------------------------------------------'
		global_offset=$((global_offset+${mpls_lengths_playlist[$global_count]}))
		global_count=$((global_count+1))
		current_mpls_playlist_of_m2ts=()
		echo "$mt2s_in_mpls_playlist in ${mpls_playlist[$global_count]}"
		mt2s_in_mpls_playlist_length=$(ffprobe -i "../STREAM/$mt2s_in_mpls_playlist" -show_entries format=duration -v quiet -of csv="p=0")
		
		if (( $(echo "$mt2s_in_mpls_playlist_length <= 300.0" | bc -l) ));
		then
			echo "$mt2s_in_mpls_playlist" VIDEO LENGTH WARNING
		fi
		
		current_mpls_playlist_of_m2ts+=("../STREAM/$mt2s_in_mpls_playlist")
		m2ts_count=1
	fi
done

# final conversions and mux
convert_m2ts_to_mkv_and_correct $current_mpls_playlist_of_m2ts $2 $3 $4 $5 $6 $7 $8
mux_mkv_to_m2ts $current_mpls_playlist_of_m2ts $global_offset $global_count $4 $5 $6 $8
current_mpls_playlist_of_m2ts=()

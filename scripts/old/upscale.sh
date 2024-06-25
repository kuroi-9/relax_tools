if [ "$1" = "" ]
then
	echo "Usage: <pics extension> <base quality(low/medium)>"
else
	mkdir upscaled_pics

	for picture in *;
	do
		filename=$(basename "$picture")
		extension=${filename##*.}
		
		if [ "$extension" = "$1" ]
		then
			# Low quality to High quality
			if [ "$2" = "low" ]
			then
				/home/loicd/Téléchargements/waifu2x-ncnn-vulkan-20220728-ubuntu/./waifu2x-ncnn-vulkan -i "$picture" -o output_temporaire."$1" -n 0 -s 2 >/dev/null 2>&1
				ffmpeg -i output_temporaire."$1" -vf scale=1404:-1 upscaled_pics/"$picture" > /dev/null 2>&1
			fi
			
			# Medium quality to High/Ultra quality
			if [ "$2" = "medium" ]
			then
				/home/loicd/Téléchargements/waifu2x-ncnn-vulkan-20220728-ubuntu/./waifu2x-ncnn-vulkan -i "$picture" -o output_temporaire."$1" -n -1 -s 2 >/dev/null 2>&1
				ffmpeg -i output_temporaire."$1" -vf scale=1404:-1 upscaled_pics/"$picture" > /dev/null 2>&1
			fi
			
			rm output_temporaire."$1"
			echo "[UPSCALED] $picture"
		else
			echo KO
		fi
	done
fi

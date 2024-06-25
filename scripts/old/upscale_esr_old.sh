if [ "$1" = "" ]
then
	echo "Usage: <pics extension> <base quality(low/medium)>"
else
	mkdir upscaled_pics

	for picture in *;
	do
		filename=$(basename "$picture")
		extension=${filename##*.}
		basename="${filename%.*}"
		
		if [ "$extension" = "$1" ]
		then
			#safe png to jpg
			ffmpeg -i "$picture" output_temporaire1.jpg -y >/dev/null 2>&1
			
			# Low quality to High quality
			if [ "$2" = "nt" ];
			then
				check=false
				tries=1
				
				while [ "$check" != true -a "$tries" -le 3 ] 
				do
					ffmpeg -i output_temporaire1.jpg -vf scale=1404:-1 output_temporaire2.jpg -y >/dev/null 2>&1
					/home/loicd/Téléchargements/realesrgan-ncnn-vulkan-v0.2.0-ubuntu/./realesrgan-ncnn-vulkan -i output_temporaire2.jpg -s 4 -n realesr-animevideov3-x4 -o output_temporaire.jpg >/dev/null 2>&1
					ffmpeg -i output_temporaire.jpg -compression_level 53 upscaled_pics/"$basename".jpg -y >/dev/null 2>&1
					stat=$(convert upscaled_pics/"$basename".jpg -colorspace RGB -format %c  -depth 8  histogram:info:-|grep -i '#00000' | wc | awk 'NR > 0 {print $1}')
					
					if [ "$stat" -eq 1 ]
					then
						echo "[FAIL, redo]"
						rm upscaled_pics/"$basename".jpg
						tries=$((tries+1))
					else
						check=true
					fi
				done
					
				echo "[UPSCALED cesr] $picture; $basename.jpg"
			fi
			
			# Medium quality to High/Ultra quality
			if [ "$2" = "downscale" ];
			then
				ffmpeg -i output_temporaire1.jpg -vf scale=1404:-1 upscaled_pics/"$basename".jpg -y >/dev/null 2>&1
				echo "[DOWNSCALED sesr] $picture"
			fi
			
			rm output_temporaire1.jpg
			
		else
			echo KO
		fi
	done
fi

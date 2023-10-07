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
			file=upscaled_pics/"$basename".jpg
				
			if [ -f "$file" ]; then
				echo "$file exists, skipping"
			else
				# Low quality to High quality
				if [ "$2" = "nt" ];
				then		
					# safe png to jpg
					ffmpeg -i "$picture" output_temporaire1.jpg -y >/dev/null 2>&1
					check=false
					tries=1
					
					# first pass
					while [ "$check" != true -a "$tries" -le 3 ] 
					do
						/home/loicd/Téléchargements/realesrgan-ncnn-vulkan-v0.2.0-ubuntu/./realesrgan-ncnn-vulkan -i output_temporaire1.jpg -s 4 -n realesr-animevideov3-x4 -o output_temporaire3.jpg >/dev/null 2>&1
						ffmpeg -i output_temporaire3.jpg -compression_level 71 upscaled_pics/"$basename".jpg -y >/dev/null 2>&1
						stat=$(convert upscaled_pics/"$basename".jpg -colorspace RGB -format %c  -depth 8  histogram:info:-|grep -i '#00000' | wc | awk 'NR > 0 {print $1}')
						
						if [ "$stat" -eq 1 -a "$tries" -ne 3 ]
						then
							echo "[FAIL, redo]"
							rm upscaled_pics/"$basename".jpg
							rm output_temporaire3.jpg
							tries=$((tries+1))
						else
							check=true
						fi
					done
					
					rm output_temporaire2.jpg > /dev/null 2>&1
					rm output_temporaire3.jpg > /dev/null 2>&1
					tries=1
					check=false
					
					# second pass
					while [ "$check" != true -a "$tries" -le 3 ] 
					do
						ffmpeg -i upscaled_pics/"$basename".jpg output_temporaire1.jpg -y > /dev/null 2>&1
						/home/loicd/Téléchargements/realesrgan-ncnn-vulkan-v0.2.0-ubuntu/./realesrgan-ncnn-vulkan -i output_temporaire1.jpg -s 4 -n realesr-animevideov3-x4 -o output_temporaire3.jpg > /dev/null 2>&1
						ffmpeg -i output_temporaire3.jpg -compression_level 71 output_temporaire2.jpg -y >/dev/null 2>&1
						ffmpeg -i output_temporaire2.jpg -vf scale=3840:2160 upscaled_pics2/"$basename".jpg -y >/dev/null 2>&1
						stat=$(convert upscaled_pics2/"$basename".jpg -colorspace RGB -format %c  -depth 8  histogram:info:-|grep -i '#00000' | wc | awk 'NR > 0 {print $1}')
						
						if [ "$stat" -eq 1 -a "$tries" -ne 3 ]
						then
							echo "[FAIL, redo]"
							rm upscaled_pics2/"$basename".jpg
							rm output_temporaire3.jpg
							tries=$((tries+1))
						else
							check=true
						fi
					done
					
					rm upscaled_pics/"$basename".jpg > /dev/null 2>&1
					rm output_temporaire1.jpg > /dev/null 2>&1
					rm output_temporaire2.jpg > /dev/null 2>&1
					rm output_temporaire3.jpg > /dev/null 2>&1
					
					echo "[UPSCALED 4K dcesr][`date`]$picture"
				fi
				
				# checking output files
				for uscaled_pic in upscaled_pics/*
				do
					stat=$(convert upscaled_pics2/"$basename".jpg -colorspace RGB -format %c  -depth 8  histogram:info:-|grep -i '#00000' | wc | awk 'NR > 0 {print $1}')
					if [ "$stat" -eq 1 ]
					then
						echo "[FAILED, $picture]"
					else
						echo "[SUCCEEDED, $picture]"
					fi
				done
			fi
			
			# Medium quality to High/Ultra quality
			if [ "$2" = "downscale" ];
			then
				convert output_temporaire1.jpg -resample 216 output_temporaire2.jpg >/dev/null 2>&1
				ffmpeg -i output_temporaire2.jpg -compression_level 71 upscaled_pics/"$basename".jpg -y >/dev/null 2>&1
				echo "[DOWNSCALED sesr] $picture"
			fi
			
			rm output_temporaire1.jpg > /dev/null 2>&1
			rm output_temporaire2.jpg > /dev/null 2>&1
		else
			echo KO
		fi
	done
fi

suspend

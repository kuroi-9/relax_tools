#!/bin/bash

mkdir upscaled_pics > /dev/null 2>&1

processed=0
errors=0
nb_tests=0
starting_res=1970

for picture in *;
do	
	
		filename=$(basename "$picture")
		extension=${filename##*.}
		basename="${filename%.*}"
		
		file=upscaled_pics/"$basename".jpg
		
		# Do not processes upscale if output file already exists
		if [ -f "$file" ]; then
			echo -e "${GRAY}$file exists, skipping${NC}\r"
			processed=$((processed + 1))
		else
			# Preset 1, low to high quality or TOO high quality to high (= helps with Moiré effect) 
			if [ "$processed" = "$2" ]
			then
				while [ "$nb_tests" -le "$3" ];
				do
					processing=$((nb_tests * 100))
					processing=$((processing / $3))
				
					if [ "$processing" -ge 100 ];
					then
						processing=100
					fi
					
					echo -ne "Testing res $starting_res... $processing%\r"
					
					if [ "$1" = "nt" ];
					then
						#safe png to jpg
						ffmpeg -i "$picture" -vf scale=-1:"$starting_res" output_temporaire2.jpg -y > /dev/null 2>&1
					
						check=false
						tries=1
						
						# Upscaling up to 3 times if it fails
						while [ "$check" != true -a "$tries" -le 3 ] 
						do
							/home/loicd/Téléchargements/realesrgan-ncnn-vulkan-v0.2.0-ubuntu/./realesrgan-ncnn-vulkan -i output_temporaire2.jpg -s 4 -n realesr-animevideov3-x4 -o output_temporaire3.jpg > /dev/null 2>&1
							ffmpeg -i output_temporaire3.jpg -compression_level 71 upscaled_pics/"$basename"_"$starting_res".jpg -y > /dev/null 2>&1
							
							if [ -f upscaled_pics/"$basename"_"$starting_res".jpg ];
							then
								stat=$(convert upscaled_pics/"$basename"_"$starting_res".jpg -colorspace RGB -format %c -depth 8 histogram:info:- | grep -i '#00000' | wc | awk 'NR > 0 {print $1}')
							fi
							
							# If histogram reports full black, an error is supposed
							if [ "$stat" != "" ];
							then
								if [ "$stat" -eq 1 -a "$tries" -lt 3 ]
								then
									rm upscaled_pics/"$basename"_"$starting_res".jpg
									rm output_temporaire3.jpg
									tries=$((tries+1))
								elif [ "$stat" -eq 1 -a "$tries" -eq 3 ];
								then
									rm upscaled_pics/"$basename"_"$starting_res".jpg
									rm output_temporaire3.jpg
									echo -e "${RED}[FAILED or BLACK] $filename${NC}\r"
									errors=$((errors + 1))
									tries=$((tries+1))
								else
									check=true
								fi
							else
								check=true
							fi
						done
						
						rm output_temporaire2.jpg > /dev/null 2>&1
						rm output_temporaire3.jpg > /dev/null 2>&1
					fi
					
					nb_tests=$((nb_tests + 1))
					starting_res=$((starting_res + 1))
				done
			fi
			
			processed=$((processed + 1))
		fi
	
done

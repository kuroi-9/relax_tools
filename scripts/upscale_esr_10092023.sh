#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
LIGHT_BLUE='\033[0;94m'
NC='\033[0m'

function cleanup() {
    tput cnorm
    echo -e ${NC}
}

trap cleanup EXIT
tput civis

# Newbie trap
if [ "$1" = "" ]
then
	echo "Usage: <base quality(nt, ...)>"
else
	mkdir upscaled_pics > /dev/null 2>&1
	processed=0
	errors=0
	
	rm output_temporaire2.jpg > /dev/null 2>&1
	rm output_temporaire3.jpg > /dev/null 2>&1
	
	imagesCountTemp=$(ls | grep ".jpg" | wc -l)
	imagesCountTemp2=$(ls | grep ".png" | wc -l)
	imagesCountTemp3=$(ls | grep ".jpeg" | wc -l)
	imagesCount=$((imagesCountTemp + imagesCountTemp2 + imagesCountTemp3))

	#TODO: add jpeg compatibility (imageCount fails when += jpeg files wc -l)
	
	#echo -e "${GREEN}Starting with argv=[$1]...${NC}\r"

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
			processing=$((processed * 100))
			processing=$((processing / imagesCount))
		
			if [ "$processing" -ge 100 ];
			then
				processing=100
			fi
			
			echo -ne "Processing... $processing% [$processed/$imagesCount]\r"
			
			# Preset 1, low to high quality or TOO high quality to high (= helps with Moiré effect) 
			if [ "$1" = "nt" ];
			then
				#safe png to jpg
				ffmpeg -i "$picture" -vf scale=-1:2015 output_temporaire2.jpg -y > /dev/null 2>&1
				#ffmpeg -i "$picture" output_temporaire2.png -y > /dev/null 2>&1
			
				check=false
				tries=1
				
				# Upscaling up to 3 times if it fails
				while [ "$check" != true -a "$tries" -le 3 ] 
				do
					/home/loicd/Téléchargements/realesrgan-ncnn-vulkan-v0.2.0-ubuntu/./realesrgan-ncnn-vulkan -i output_temporaire2.jpg -s 4 -n realesr-animevideov3-x4 -o output_temporaire3.jpg > /dev/null 2>&1
					ffmpeg -i output_temporaire3.jpg -compression_level 71 upscaled_pics/"$basename".jpg -y > /dev/null 2>&1
					
					if [ -f upscaled_pics/"$basename".jpg ];
					then
						stat=$(convert upscaled_pics/"$basename".jpg -colorspace RGB -format %c -depth 8 histogram:info:- | grep -i '#00000' | wc | awk 'NR > 0 {print $1}')
					fi
					
					# If histogram reports full black, an error is supposed
					if [ "$stat" != "" ];
					then
						if [ "$stat" -eq 1 -a "$tries" -lt 3 ]
						then
							rm upscaled_pics/"$basename".jpg
							rm output_temporaire3.jpg
							tries=$((tries+1))
						elif [ "$stat" -eq 1 -a "$tries" -eq 3 ];
						then
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
			
			processed=$((processed + 1))
		fi
	done
	
	if [ "$2" = "-c" ];
	then
		# checking output files
		nbCheckedOutputFiles=0
		outputImagesCount=$(ls upscaled_pics/ | wc -l)
		
		for upscaled_pic in upscaled_pics/*;
		do
			echo -ne "Checking... $((nbCheckedOutputFiles * 100 / outputImagesCount))%     \r"

			filename=$(basename "$upscaled_pic")
			extension=${filename##*.}
			basename="${filename%.*}"
			stat=$(convert upscaled_pics/"$basename".jpg -colorspace RGB -format %c  -depth 8  histogram:info:-|grep -i '#00000' | wc | awk 'NR > 0 {print $1}')

			if [ "$stat" -eq 1 ]
			then
				echo -e "${RED}[FAILED or BLACK] $filename${NC}\r"
				errors=$((errors + 1))
				nbCheckedOutputFiles=$((nbCheckedOutputFiles + 1))
			else
				nbCheckedOutputFiles=$((nbCheckedOutputFiles + 1))
			fi
		done
	else
		sleep 5
	fi
	
	# Return 0 if OK, 1 if it may be an error (= user check intended)
	if [ "$errors" -ge 1 ];
	then
		echo -ne "Finished with potential ${RED}$errors errors${NC}. Please check it out.\r" && echo ""
		exit 1
	else
		echo -ne "${LIGHT_BLUE}Finished without potential errors :)${NC}\r" && echo ""
		exit 0
	fi
fi

#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
NC='\033[0m'

function cleanup() {
    tput cnorm
	kill $pid > /dev/null 2>&1
    echo -e ${NC}
}

trap cleanup EXIT
tput civis
mkdir out > /dev/null 2>&1
clear

filesCount=$(ls | grep '.cbz' | wc -l)
processedFiles=0
workingDir=$(pwd)
history=()

echo -e "------- $processedFiles sur $filesCount -------------------------------------------------------------------"

# Processes all .cbz files of the current directory
for cbz in *.cbz;
do	
	filename=$(basename "$cbz")
	extension=${filename##*.}
	basename="${filename%.*}"
	
	mkdir "${cbz%.*}" >/dev/null 2>&1
	file=out/"$basename"	
	
	# If output file exists, manage history accordingly
	if [ -f "$file".cbz ];
	then
		echo -e "${GRAY}[FOUND] ${cbz%.*} \u2714${NC}\r"
		history+=("${GRAY}[FOUND] ${cbz%.*} \u2714${NC}\r")
		processedFiles=$((processedFiles + 1))
		rm -rf "${cbz%.*}"
		clear
	elif [ -f "$file"_potential_errors.cbz ];
	then
		echo -e "${RED}[FOUND] ${cbz%.*} \u2718${NC}\r"
		history+=("${RED}[FOUND] ${cbz%.*} \u2718${NC}\r")
		processedFiles=$((processedFiles + 1))
		rm -rf "${cbz%.*}"
		clear
	else
		unzip -o "$cbz" -d "${cbz%.*}" > /dev/null 2>&1
		cd "${cbz%.*}"
		cd * > /dev/null 2>&1
		cd * > /dev/null 2>&1
		mkdir ~/Documents/to_upscale/"${PWD##*/}" && mv * ~/Documents/to_upscale/"${PWD##*/}"
		
		# preparing directory
		cd ~/Documents/to_upscale/"${PWD##*/}"
		for picture in *;
		do
			filename=$(basename "$picture")
			extension=${filename##*.}
			basename="${filename%.*}"
			
			file=~/Documents/upscale_out/"${PWD##*/}"/"$basename".jpg
			
			# Do not processes upscale if output file already exists
			if [ -f "$file" ]; then
				echo -e "${GRAY}$file exists, skipping${NC}\r"
				rm "$picture"
			fi
		
		# running chainner
		
		
		cd "$workingDir"
		rm -rf "${cbz%.*}"
	fi
	
	# Display history at each iteration (= .cbz)
	clear
	echo -e "------- $processedFiles sur $filesCount -------------------------------------------------------------------"
	for value in "${history[@]}"
	do	
		echo -e $value
	done
done

#systemctl suspend
#-sing my pleasure-

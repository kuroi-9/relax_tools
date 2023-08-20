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

echo -e "------- $processedFiles sur $filesCount ------------------------------------------------------------------------"

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
		echo -e "${GREEN}[FOUND] ${cbz%.*} \u2714${NC}\r"
		history+=("${GREEN}[FOUND] ${cbz%.*} \u2714${NC}\r")
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
		
		# Starting subprocess and get it's return value
		echo -ne "[`date`] ${cbz%.*}\r" && echo ""
		upscale_esr_20082023.sh nt &
		pid=$!
		wait $pid
		doneWithErrors=$?
		
		# Create different filename for alarming and $history purposes
		if [ "$doneWithErrors" -eq 1 ];
		then
			zip -r "$workingDir"/out/"$basename"_potential_errors.cbz upscaled_pics/ > /dev/null 2>&1
		else
			zip -r "$workingDir"/out/"$cbz" upscaled_pics/ > /dev/null 2>&1
		fi

		cd "$workingDir"
		rm -rf "${cbz%.*}"
			
		# History managing
		if [ -f "$file".cbz -a "$doneWithErrors" -eq 0 ];
		then
			processedFiles=$((processedFiles + 1))
			history+=("${GREEN}[`date`] ${cbz%.*} \u2714${NC}\r")
		elif [ -f "$file"_potential_errors.cbz -a "$doneWithErrors" -eq 1 ];
		then
			processedFiles=$((processedFiles + 1))
			history+=("${RED}[`date`] ${cbz%.*} \u2718${NC}\r")
		fi
	fi
	
	# Display history at each iteration (= .cbz)
	clear
	echo -e "------- $processedFiles sur $filesCount ------------------------------------------------------------------------"
	for value in "${history[@]}"
	do	
		echo -e $value
	done
done

#systemctl suspend
#dougdoug

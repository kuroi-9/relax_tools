#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
NC='\033[0m'
#export DISPLAY=$HOST_IP:1

function cleanup() {
    tput cnorm
	kill $pid > /dev/null 2>&1
    echo -e ${NC}
}

trap cleanup EXIT
tput civis

if [ $(ls -1 out/ | grep "_potential_errors.cbz" | wc -l) -ge 1 ];
then
	clear
	for cbz in out/*_potential_errors.cbz;
	do
		echo -e "${RED}$cbz${NC}"
	done
	echo "These files will be deleted. Continue ? (y/n)"
	read res
	
	if [ "$res" = "y" -o "$res" = "" ];
	then
		rm -rf out/*_potential_errors.cbz > /dev/null 2>&1
		echo "Files removed."
	else
		echo "Files not removed."
	fi
fi

mkdir out/ > /dev/null 2>&1
clear

filesCount=$(ls | grep '.cbz' | wc -l)
processedFiles=0
workingDir=$(pwd)
history=()
diskUsableSpace=$(df --output=avail --block-size=1024 . | sed 1d)
diskUsedSpace=0
notEnoughSpace=false

echo -e "|--------------------- $processedFiles of $filesCount ----------------------vPinkValentine"

# Processes all .cbz files of the current directory
for cbz in *.cbz;
do	
	filename=$(basename "$cbz")
	extension=${filename##*.}
	basename="${filename%.*}"
	diskUsableSpace=$(df --output=avail --block-size=1024 . | sed 1d)
	fileSize=$(ls -l --block-size=1024 "$cbz" | cut -d ' ' -f 5)
	
	if [ -d ~/Documents/upscale_out/"${cbz%.*}" ];
	then
		diskUsedSpace=$(du -s ~/Documents/upscale_out/"${cbz%.*}" | cut -d '/' -f 1)
	fi
	
	mkdir "${cbz%.*}" >/dev/null 2>&1
	file=out/"$basename"	
	
	# If output file exists, manage history accordingly
	if [ -f "$file".cbz ];
	then
		echo -e "| ${GRAY}[FOUND] ${cbz%.*} \u2714${NC}\r"
		history+=("| ${GRAY}[FOUND] ${cbz%.*} \u2714${NC}\r")
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
		echo -ne "[`date`] ${cbz%.*}\r" && echo ""
		if [ $((fileSize * 35 - diskUsedSpace)) -gt 0 -a $diskUsableSpace -gt $((fileSize * 35 - diskUsedSpace)) ];
		then
			unzip -o "$cbz" -d "${cbz%.*}" > /dev/null 2>&1
			cd "${cbz%.*}"
			mkdir ci_temp
			find . \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' \) -print0 | xargs -0 cp -t ci_temp
			cd ci_temp
			cg_path=$(dirname "${PWD}")
			#rm -rf ~/Documents/to_upscale/* > /dev/null 2>&1
			file_count=$(ls -1 | wc -l)
			mkdir ~/Documents/to_upscale/"${cg_path##*/}" > /dev/null 2>&1 && mv * ~/Documents/to_upscale/"${cg_path##*/}" > /dev/null 2>&1
			cd .. && rm -rf ../"${cbz%.*}"
			
			# preparing directory
			cd ~/Documents/to_upscale/"${PWD##*/}"
			
			if [ -d ~/Documents/upscale_out/"${PWD##*/}" ];
			then
				for picture in *;
				do
					sub_filename=$(basename "$picture")
					sub_extension=${sub_filename##*.}
					sub_basename="${sub_filename%.*}"
					
					upscaled_file=~/Documents/upscale_out/"${PWD##*/}"/"$sub_basename".jpg
					
					# Do not processes upscale if output file already exists
					if [ -f "$upscaled_file" ]; 
					then
						#TODO CHECK IF BETTER WAY TO DISPLAY ALREADY UPSCALED PICS
						#echo -e "${GRAY}$upscaled_file exists, skipping${NC}\r"
						rm "$picture"
					fi
				done
			else
				mkdir ~/Documents/upscale_out/"${PWD##*/}" > /dev/null 2>&1
			fi

			# preparing the input/output for chainner
			inputs_json=$(cat ~/relax_tools/scripts/upscale_esr_library_14022024_inputs.json)
			updated_json=$(echo "$inputs_json" | jq --arg source_pics_dir "${PWD}" '.inputs["#7b571afb-67e4-47f3-a412-4209c77ee8db:0"] = $source_pics_dir')
			final_json=$(echo "$updated_json" | jq --arg output_subdir "${PWD##*/}" '.inputs["#f7235232-fc28-4eae-aa73-b4425e2d4b9b:2"] = $output_subdir')
			echo $final_json > ~/relax_tools/scripts/upscale_esr_library_14022024_inputs_latest.json
			
			# running chainner
			~/Téléchargements/chaiNNer-linux-x64/./chainner run ~/Documents/upscale_esr_24062024  --override "/home/loic/relax_tools/scripts/upscale_esr_library_14022024_inputs_latest.json" > /dev/null 2>&1 &
			pid=$!
			
			# beautiful declaration UwU
			spinner="/-\\|"
			
			processing_time=0
			last_processed_file_count=$(ls -1 ~/Documents/upscale_out/"${PWD##*/}"/ | wc -l)
			average_processing_time=0
			total_processing_time=0
			current_processed_file_count=0
			estimated_remaining_time=0
			
			while true; 
			do
				processed_file_count=$(ls -1 ~/Documents/upscale_out/"${PWD##*/}"/ | wc -l)
				remaining_files=$((file_count - processed_file_count))
				
				if [ "$processed_file_count" -gt "$last_processed_file_count" ];
				then
					last_processed_file_count=$processed_file_count
					current_processed_file_count=$((current_processed_file_count + 1))
					total_processing_time=$((total_processing_time + processing_time))
					average_processing_time=$((total_processing_time / current_processed_file_count))
					processing_time=0
					
					estimated_remaining_time=$((remaining_files * average_processing_time))
					current_time=$(date +%s)
					end_time=$((current_time + estimated_remaining_time + 60))
					end_time_formatted=$(date -d @$end_time +"%H:%M")
				fi

				echo -ne "	Running... [${GREEN}$processed_file_count${NC}/$file_count][ETA => ${GREEN}$([[ $end_time_formatted = "" ]] && echo "${RED}... ${NC}" || echo "$end_time_formatted")${NC}]\r"

				printf "[%c] " "${spinner:SECONDS % ${#spinner}:1}" 

				if ! ps -p $pid > /dev/null; 
				then
					if [ $processed_file_count -lt $file_count ];
					then
						# re-running chainner
						echo -ne "	${GRAY}Halted: [$processed_file_count/$file_count][ETA => $([[ $end_time_formatted = "" ]] && echo "... ${NC}" || echo "$end_time_formatted")${NC}]\r"
						~/Téléchargements/chaiNNer-linux-x64/./chainner run ~/Documents/upscale_esr_24062024  --override "/home/loic/relax_tools/scripts/upscale_esr_library_14022024_inputs_latest.json" > /dev/null 2>&1 &
						pid=$!
					else
						echo -ne "	Finalizing... [${GREEN}$processed_file_count${NC}/$file_count][ETA => ${GREEN}$([[ $end_time_formatted = "" ]] && echo "${RED}... ${NC}" || echo "$end_time_formatted")${NC}]\r"
						break
					fi
				fi
				
				processing_time=$((processing_time + 1))
				sleep 1
			done

			end_time_formatted=""
			doneWithErrors=$?
			out_file_count=$(ls -1 ~/Documents/upscale_out/"${PWD##*/}"/ | wc -l)
			
			# Create different filename for alarming and $history purposes
			if [ "$out_file_count" -eq "$file_count" -o "$out_file_count" -eq $((file_count - 1)) ];
			then
				zip -r "$workingDir"/out/"$cbz" ~/Documents/upscale_out/"${PWD##*/}"/ > /dev/null 2>&1
				if [ -f "$workingDir"/out/"$cbz" ];
				then
					echo "zip process success"
				else
					echo "${RED}zip process failed, enough disk space ?${NC}"
				fi
			else
				zip -r "$workingDir"/out/"$basename"_potential_errors.cbz ~/Documents/upscale_out/"${PWD##*/}"/ > /dev/null 2>&1
				if [ -f "$workingDir"/out/"$basename"_potential_errors.cbz ];
				then
					echo "zip process success"
				else
					echo "${RED}zip process failed, enough disk space ?${NC}"
				fi
			fi
			
			rm -rf ~/Documents/to_upscale/"${PWD##*/}"
			rm -rf "${cbz%.*}"
			cd "$workingDir"
				
			# History managing
			clear
			if [ -f "$file".cbz -a \( "$out_file_count" -eq $file_count -o "$out_file_count" -eq $((file_count - 1)) \) ];
			then
				processedFiles=$((processedFiles + 1))
				history+=("| ${GREEN}[`date`] ${cbz%.*} \u2714${NC}\r")
			elif [ -f "$file"_potential_errors.cbz -a \( "$out_file_count" -eq $file_count -o "$out_file_count" -eq $((file_count - 1)) \) ];
			then
				processedFiles=$((processedFiles + 1))
				history+=("${RED}[`date`] ${cbz%.*} \u2718 [$file_count/$out_file_count]${NC}\r")
			fi
		else
			rm -rf "${cbz%.*}"
			history+=("${RED}Not enough disk space to continue [$(( (fileSize * 35 - diskUsedSpace - diskUsableSpace) / 1024))MB required]. Abording.${NC}")
			notEnoughSpace=true
		fi
	fi
	
	# Display history at each iteration (= .cbz)
	clear
	echo -e "|--------------------- $processedFiles of $filesCount ----------------------vPinkValentine"
	for value in "${history[@]}"
	do	
		echo -e $value
	done
	if [ "$notEnoughSpace" = true ];
	then
		break
	fi
done

#systemctl suspend
#-sing my pleasure-

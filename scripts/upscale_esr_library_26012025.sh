#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
NC='\033[0m'
export DISPLAY=$HOST_IP:0

function cleanup() {
    tput cnorm
	kill $pid > /dev/null 2>&1
    echo -e ${NC}
}

# Initialiser les variables par défaut
path=""

VALID_ARGS=$(getopt -o p: --long path: -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

# Parse les options
eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -p | --path)
        path=$2
        shift 2
        ;;
    --) shift;
        break
        ;;
  esac
done

# Vérifier que le chemin est défini
# last_pid étant optionnel, on ne le vérifie pas
if [[ -z "$path" ]]; then
  echo "Vous devez fournir un chemin avec l'option --path ou -p."
  exit 1
fi

cd "$path"

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

echo -e "|--------------------- $processedFiles of $filesCount ----------------------vFatal"

# Processes all .cbz files of the current directory
for cbz in *.cbz;
do	
	filename=$(basename "$cbz")
	extension=${filename##*.}
	basename="${filename%.*}"
	diskUsableSpace=$(df --output=avail --block-size=1024 . | sed 1d)
	fileSize=$(ls -l --block-size=1024 "$cbz" | cut -d ' ' -f 5)
	
	if [ -d ~/Documents/Mangas/manga_upscale/upscale_out/"${cbz%.*}" ];
	then
		diskUsedSpace=$(du -s ~/Documents/Mangas/manga_upscale/upscale_out/"${cbz%.*}" | cut -d '/' -f 1)
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
		touch ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${cbz%.*}"/completed.lock
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
		#if [ $((fileSize * 35 - diskUsedSpace)) -gt 0 -a $diskUsableSpace -gt $((fileSize * 35 - diskUsedSpace)) ];
		#then
			unzip -o "$cbz" -d "${cbz%.*}" > /dev/null 2>&1
			cd "${cbz%.*}"
			mkdir ci_temp
			find . \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0 | xargs -0 cp -t ci_temp
			cd ci_temp
			cg_path=$(dirname "${PWD}")
			#rm -rf ~/Documents/Mangas/manga_upscale/to_upscale/* > /dev/null 2>&1
			file_count=$(ls -1 | wc -l)
			rm -rf ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${cg_path##*/}" > /dev/null 2>&1
			mkdir ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}" > /dev/null 2>&1
			mkdir ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${cg_path##*/}" > /dev/null 2>&1
			mv * ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${cg_path##*/}" > /dev/null 2>&1
			cd .. && rm -rf ../"${cbz%.*}"
			
			# preparing directory
			cd ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${PWD##*/}"

			if [ -d ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}" ];
			then
				for picture in *;
				do
					sub_filename=$(basename "$picture")
					sub_extension=${sub_filename##*.}
					sub_basename="${sub_filename%.*}"
					
					upscaled_file=~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/"$sub_basename".jpg
					
					# Do not processes upscale if output file already exists
					if [ -f "$upscaled_file" ]; 
					then
						#TODO CHECK IF BETTER WAY TO DISPLAY ALREADY UPSCALED PICS
						#echo -e "${GRAY}$upscaled_file exists, skipping${NC}\r"
						rm "$picture"
					fi
				done
			else
				mkdir ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}" > /dev/null 2>&1
				mkdir ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}" > /dev/null 2>&1
				echo $file_count > ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/file_count
			fi

			echo $$ > ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/last_pid
			rm -rf ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/launcher.lock

			# preparing the input/output for chainner
			inputs_json=$(cat ~/relax_tools/scripts/upscale_esr_library_26012025_inputs.json)
			updated_json=$(echo "$inputs_json" | jq --arg source_pics_dir "${PWD}" '.inputs["#7b571afb-67e4-47f3-a412-4209c77ee8db:0"] = $source_pics_dir')
			final_json=$(echo "$updated_json" | jq --arg output_subdir "${workingDir##*/}"/"${PWD##*/}" '.inputs["#f7235232-fc28-4eae-aa73-b4425e2d4b9b:2"] = $output_subdir')
			echo $final_json > ~/relax_tools/scripts/upscale_esr_library_26012025_inputs_latest.json

			# Running chainner.

			# Second RESIZE TO SIDE element note :
			# We should multiply 1814 by the following dividing (old screen height/new screen height)
			# The result then should be multiplied by 4.
			killall chainner
			~/Downloads/chaiNNer-linux-x64/./chainner run /home/loicd/relax_tools/upscale/manga/workers/upscale_esr_26012025.chn  --override "/home/loicd/relax_tools/scripts/upscale_esr_library_26012025_inputs_latest.json" > /dev/null 2>&1 &
			pid=$!
			
			# beautiful declaration UwU
			spinner="/-\\|"
			
			processing_time=0
			last_processed_file_count=$(ls -1 ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ | wc -l)
			average_processing_time=0
			total_processing_time=0
			current_processed_file_count=0
			estimated_remaining_time=0
			
			while true; 
			do
				processed_file_count=$(ls -1 ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ | wc -l)
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
					echo $end_time > ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/eta
					end_time_formatted=$(date -d @$end_time +"%H:%M")
				fi

				echo -ne "	Running... [${GREEN}$processed_file_count${NC}/$file_count][ETA => ${GREEN}$([[ $end_time_formatted = "" ]] && echo "${RED}... ${NC}" || echo "$end_time_formatted")${NC}]\r"

				printf "[%c] " "${spinner:SECONDS % ${#spinner}:1}" 

				if ! ps -p $pid > /dev/null; 
				then
					if [ $processed_file_count -lt $file_count ];
					then
						# Trying again running chainner if the process stops prematurely
						killall chainner
						killall python3.11
						echo -ne "	${GRAY}Halted: [$processed_file_count/$file_count][ETA => $([[ $end_time_formatted = "" ]] && echo "... ${NC}" || echo "$end_time_formatted")${NC}]\r"
						~/Downloads/chaiNNer-linux-x64/./chainner run /home/loicd/relax_tools/upscale/manga/workers/upscale_esr_26012025.chn  --override "/home/loicd/relax_tools/scripts/upscale_esr_library_26012025_inputs_latest.json" > /dev/null 2>&1 &
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
			out_file_count=$(ls -1 ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ | wc -l)
			
			# Create different filename for alarming and $history purposes
			if [ "$out_file_count" -eq "$file_count" -o "$out_file_count" -eq $((file_count - 1 )) -o "$out_file_count" -eq $((file_count - 2 )) -o "$out_file_count" -eq $((file_count - 3 )) -o "$out_file_count" -eq $((file_count + 1 )) -o "$out_file_count" -eq $((file_count + 2 )) -o "$out_file_count" -eq $((file_count + 3 )) ];
			then
				zip -r "$workingDir"/out/"$cbz" ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ > /dev/null 2>&1
				if [ -f "$workingDir"/out/"$cbz" ];
				then
					echo "zip process success"
					touch ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/completed.lock
				else
					echo "${RED}zip process failed, enough disk space ?${NC}"
				fi
			else
				zip -r "$workingDir"/out/"$basename"_potential_errors.cbz ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ > /dev/null 2>&1
				if [ -f "$workingDir"/out/"$basename"_potential_errors.cbz ];
				then
					echo "zip process success"
					touch ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/completed_potential_errors.lock
				else
					echo "${RED}zip process failed, enough disk space ?${NC}"
				fi
			fi
			
			rm -rf ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${PWD##*/}"
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
		#else
			#rm -rf "${cbz%.*}"
			#history+=("${RED}Not enough disk space to continue [$(( (fileSize * 35 - diskUsedSpace - diskUsableSpace) / 1024))MB required]. Abording.${NC}")
			#notEnoughSpace=true
		#fi
	fi

	pkill -TERM -P $$
	rm -rf ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/launcher.lock
	
	# Display history at each iteration (= .cbz)
	clear
	echo -e "|--------------------- $processedFiles of $filesCount ----------------------vFatal"
	for value in "${history[@]}"
	do	
		echo -e $value
	done
	#if [ "$notEnoughSpace" = true ];
	#then
		#break
	#fi
done

#systemctl suspend
#-sing my pleasure-

#!/bin/bash
export DISPLAY=$HOST_IP:0

# Init variables with default values
path=""

VALID_ARGS=$(getopt -o p: --long path: -- "$@")
if [[ $? -ne 0 ]]; then
	exit 1
fi

# Parsing arguments
eval set -- "$VALID_ARGS"
while [ : ]; do
	case "$1" in
	-p | --path)
		path=$2
		shift 2
		;;
	--)
		shift
		break
		;;
	esac
done

# Check if the path variable is defined
# last_pid being optional, we don't check it
if [[ -z "$path" ]]; then
	echo "[ERROR] No path provided, exiting..."
	exit 1
fi

# Kill all previous process that may be still running
for title_dir in /home/loicd/Documents/Mangas/manga_upscale/upscale_out/*
do
	for dir in "$title_dir"/*
	do
		if [ -f "$title_dir"/last_pid ];
		then
			last_pid=$(cat "$title_dir"/last_pid)
			kill -9 $last_pid > /dev/null 2>&1
		fi
	done
done

# Creating lockfile and echoing the PID to the API
titleName=$(cut -d "/" -f7 <<<"$path")
touch /home/loicd/Documents/Mangas/manga_upscale/upscale_out/"${titleName}"/launcher.lock >/dev/null 2>&1 &
echo "$$"

cd "$path"
mkdir out/ >/dev/null 2>&1

filesCount=$(ls | grep '.cbz' | wc -l)
processedFiles=0
workingDir=$(pwd)

# Processes all .cbz files of the current directory
for cbz in *.cbz; do
	filename=$(basename "$cbz")
	extension=${filename##*.}
	basename="${filename%.*}"
	mkdir "${cbz%.*}" >/dev/null 2>&1
	file=out/"$basename"

	# If output file exists, manage history accordingly
	if [ -f "$file".cbz ]; then
		processedFiles=$((processedFiles + 1))
		rm -rf "${cbz%.*}"
		mkdir ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/ > /dev/null 2>&1
		mkdir ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${cbz%.*}"/ > /dev/null 2>&1
		touch ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${cbz%.*}"/completed.lock > /dev/null 2>&1
	elif [ -f "$file"_potential_errors.cbz ]; then
		processedFiles=$((processedFiles + 1))
		rm -rf "${cbz%.*}"
	else
		unzip -o "$cbz" -d "${cbz%.*}" >/dev/null 2>&1
		cd "${cbz%.*}"
		mkdir ci_temp
		find . \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0 | xargs -0 cp -t ci_temp
		cd ci_temp
		cg_path=$(dirname "${PWD}")
		file_count=$(ls -1 | wc -l)
		rm -rf ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${cg_path##*/}" >/dev/null 2>&1
		mkdir ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}" >/dev/null 2>&1
		mkdir ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${cg_path##*/}" >/dev/null 2>&1
		mv * ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${cg_path##*/}" >/dev/null 2>&1
		cd .. && rm -rf ../"${cbz%.*}"

		# Preparing directory
		cd ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${PWD##*/}"

		if [ -d ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}" ]; then
			for picture in *; do
				sub_filename=$(basename "$picture")
				sub_extension=${sub_filename##*.}
				sub_basename="${sub_filename%.*}"

				upscaled_file=~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/"$sub_basename".jpg

				# Do not processes upscale if output file already exists
				if [ -f "$upscaled_file" ]; then
					#TODO CHECK IF BETTER WAY TO DISPLAY ALREADY UPSCALED PICS
					#echo -e "${GRAY}$upscaled_file exists, skipping${NC}\r"
					rm "$picture"
				fi
			done
		else
			mkdir ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}" >/dev/null 2>&1
			mkdir ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}" >/dev/null 2>&1
			echo $file_count >~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/file_count
		fi

		# Storing the current pid and removing the lockfile
		echo $$ >~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/last_pid
		rm -rf ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/launcher.lock

		# Preparing the input/output for chainner
		inputs_json=$(cat ~/relax_tools/scripts/upscale_esr_library_26012025_inputs.json)
		updated_json=$(echo "$inputs_json" | jq --arg source_pics_dir "${PWD}" '.inputs["#7b571afb-67e4-47f3-a412-4209c77ee8db:0"] = $source_pics_dir')
		final_json=$(echo "$updated_json" | jq --arg output_subdir "${workingDir##*/}"/"${PWD##*/}" '.inputs["#f7235232-fc28-4eae-aa73-b4425e2d4b9b:2"] = $output_subdir')
		echo $final_json >~/relax_tools/scripts/upscale_esr_library_26012025_inputs_latest.json

		# Running chainner.

		# Second RESIZE TO SIDE element note :
		# We should multiply 1814 by the following dividing (old screen height/new screen height)
		# The result then should be multiplied by 4.
		killall chainner >/dev/null 2>&1
		/home/loicd/Téléchargements/chaiNNer-linux-x64/./chainner run /home/loicd/relax_tools/upscale/manga/workers/upscale_esr_05052025.chn --override "/home/loicd/relax_tools/scripts/upscale_esr_library_26012025_inputs_latest.json" >/dev/null 2>&1 &
		pid=$!

		# Beautiful declaration UwU
		spinner="/-\\|"

		processing_time=0
		last_processed_file_count=$(ls -1 ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ | wc -l)
		average_processing_time=0
		total_processing_time=0
		current_processed_file_count=0
		estimated_remaining_time=0

		while true; do
			processed_file_count=$(ls -1 ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ | wc -l)
			remaining_files=$((file_count - processed_file_count))

			# Estimating ETA each upscaled file
			if [ "$processed_file_count" -gt "$last_processed_file_count" ]; then
				last_processed_file_count=$processed_file_count
				current_processed_file_count=$((current_processed_file_count + 1))
				total_processing_time=$((total_processing_time + processing_time))
				average_processing_time=$((total_processing_time / current_processed_file_count))
				processing_time=0

				estimated_remaining_time=$((remaining_files * average_processing_time))
				current_time=$(date +%s)
				end_time=$((current_time + estimated_remaining_time + 60))
				echo $end_time >~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/eta
				end_time_formatted=$(date -d @$end_time +"%H:%M")
			fi

			if ! ps -p $pid >/dev/null; then
				if [ $processed_file_count -lt $file_count ]; then
					# Trying again running chainner if the process stops prematurely
					killall chainner
					killall python3.11
					echo "[ERROR] Halted: [$processed_file_count/$file_count][ETA => $([[ $end_time_formatted = "" ]] && echo "..." || echo "$end_time_formatted")\r"
					/home/loicd/Téléchargements/chaiNNer-linux-x64/./chainner run /home/loicd/relax_tools/upscale/manga/workers/upscale_esr_05052025.chn --override "/home/loicd/relax_tools/scripts/upscale_esr_library_26012025_inputs_latest.json" >/dev/null 2>&1 &
					pid=$!
				else
					break
				fi
			fi

			processing_time=$((processing_time + 1))
			sleep 1
		done

		end_time_formatted=""
		doneWithErrors=$?
		out_file_count=$(ls -1 ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ | wc -l)

		# Create different filename for alarming and history purposes
		if [ "$out_file_count" -eq "$file_count" -o "$out_file_count" -eq $((file_count - 1)) -o "$out_file_count" -eq $((file_count - 2)) -o "$out_file_count" -eq $((file_count - 3)) -o "$out_file_count" -eq $((file_count + 1)) -o "$out_file_count" -eq $((file_count + 2)) -o "$out_file_count" -eq $((file_count + 3)) ]; then
			zip -r "$workingDir"/out/"$cbz" ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ >/dev/null 2>&1
			if [ -f "$workingDir"/out/"$cbz" ]; then
				touch ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/completed.lock
			else
				echo "[ERROR] Zip process failed, enough disk space ?"
			fi
		else
			zip -r "$workingDir"/out/"$basename"_potential_errors.cbz ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/ >/dev/null 2>&1
			if [ -f "$workingDir"/out/"$basename"_potential_errors.cbz ]; then
				touch ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/"${PWD##*/}"/completed_potential_errors.lock
			else
				echo "[ERROR] Zip process failed, enough disk space ?"
			fi
		fi

		rm -rf ~/Documents/Mangas/manga_upscale/to_upscale/"${workingDir##*/}"/"${PWD##*/}"
		rm -rf "${cbz%.*}"
		cd "$workingDir"

		# History managing
		if [ -f "$file".cbz -a \( "$out_file_count" -eq $file_count -o "$out_file_count" -eq $((file_count - 1)) \) ]; then
			processedFiles=$((processedFiles + 1))
		elif [ -f "$file"_potential_errors.cbz -a \( "$out_file_count" -eq $file_count -o "$out_file_count" -eq $((file_count - 1)) \) ]; then
			processedFiles=$((processedFiles + 1))
		fi
	fi

	pkill -TERM -P $$
	rm -rf ~/Documents/Mangas/manga_upscale/upscale_out/"${workingDir##*/}"/launcher.lock
done

#-sing my pleasure-

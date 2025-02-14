# Parse les options
while getopts ":p:" opt; do
  case $opt in
    p) # Option pour le chemin
      path=$OPTARG
      ;;
    \?) # Option invalide
      exit 1
      ;;
    :) # Option manquante
      exit 1
      ;;
  esac
done

# Vérifier que le chemin est défini
if [[ -z "$path" ]]; then
  exit 1
fi

# Return pid
upscale_esr_library_12072024.sh -p "$path"
echo "$?"

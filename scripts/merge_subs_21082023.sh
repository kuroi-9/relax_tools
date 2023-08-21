#【MV】誇り高きアイドル／mona（CV：夏川椎菜）【HoneyWorks】

subsCount=$(ls subs_to_add/ | wc -l)
videosCount=$(ls destination_videos/ | wc -l)
generalCount=$2

#####################################################
mkdir renamed_subs >/dev/null 2>&1

echo "Vérification des sous-titres à ajouter"

for video in source_videos/*;
do
	mkvextract tracks "$video" "$1":renamed_subs/"$generalCount".ass
	
	generalCount=$((generalCount+1))
done

generalCount=1

for sub in subs_to_add/*;
do
	cp "$sub" renamed_subs/"$generalCount".ass
	
	generalCount=$((generalCount+1))
done

for renamed_sub in renamed_subs/*;
do
	echo $renamed_sub
done

generalCount=$2

#####################################################
echo "Vérifications des vidéos destination"

for video in destination_videos/*;
do
	echo $video
done

#####################################################

echo ----------------------------------
echo "merge files ?"
read -p ""

#####################################################

for video in destination_videos/*;
do
	echo "[MERGING] renamed_subs/$generalCount.ass AND $video"
	mkvmerge -o "Épisode $generalCount".mkv renamed_subs/"$generalCount".ass "$video" >/dev/null 2>&1
	
	generalCount=$((generalCount+1))
done

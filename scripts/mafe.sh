#!/bin/bash

# base commands
website=""
mangadexBaseCommand="mangadex-downloader --save-as cbz"
mloaderBaseCommand="mloader -r --chapter-title"

# mangadex variables
mangadexMangaId=""
mangadexStartChapterId=""
mangadexEndChapterId=""
mloaderChapterId=""
mloaderOutDir=""

clear

echo "From which website ? <mangadex/mloader>"
read website
if [ "$website" = "mangadex" ];
then
	echo "Enter title mangadex ID:"
	read mangadexMangaId
	echo "Enter start chapter number:"
	read mangadexStartChapterId
	echo "Enter end chapter number:"
	read mangadexEndChapterId
	
	mangadexFetchCommand="$mangadexBaseCommand"
	
	if [ -n "$mangadexStartChapterId" ];
	then
		mangadexFetchCommand="${mangadexFetchCommand} --start-chapter $mangadexStartChapterId"
	fi
	
	if [ -n "$mangadexEndChapterId" ];
	then
		mangadexFetchCommand="${mangadexFetchCommand} --end-chapter $mangadexEndChapterId"
	fi
	
	mangadexFetchCommand="${mangadexFetchCommand} $mangadexMangaId"
	echo $mangadexFetchCommand
	echo "Proceed ? (y/n)"
	read res
	
	if [ "$res" = "y" -o "$res" = "" ];
	then
		$mangadexFetchCommand
		echo "command executed."
	else
		echo "not executed, terminating."
	fi
	
fi

if [ "$website" = "mloader" ];
then
	mkdir temp_ml > /dev/null 2>&1
	echo "Enter title chapter ID:"
	read mloaderChapterId
	echo "Enter out dirname:"
	read mloaderOutDir
	
	mloaderFetchCommand="$mloaderBaseCommand -o $mloaderOutDir -c $mloaderChapterId"
	
	echo $mloaderFetchCommand
	echo "Proceed ? (y/n)"
	read res
	
	if [ "$res" = "y" -o "$res" = "" ];
	then
		cd temp_ml && $mloaderFetchCommand
		zip ../"$mloaderOutDir".cbz -r "$mloaderOutDir"
		cd ..
		rm -rf temp_ml/"$mloaderOutDir"
		echo "command executed."
	else
		echo "not executed, terminating."
	fi
fi

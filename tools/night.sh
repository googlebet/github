#!/bin/bash

LOGFILE="git.log"
LAST="last.log"

ANDROID=~/work/android/

if [ -d "$ANDROID" ]
then
        echo "enter $ANDROID...."
        cd $ANDROID
        source build/envsetup.sh
        lunch full_maguro-userdebug
else
        echo "Error...."
fi

if  [ -e "$LAST" ]
then
	LAST_TAG=`cat "$LAST"`
else
	LAST_TAG="0000"
fi
echo "last $LAST_TAG"

if [ -e "$LOGFILE" ]
then
	rm -f $LOGFILE
fi

echo "update git repo"
/home/tt/bin/pullrepo

git log --date=local >$LOGFILE 
#cp $LOGFILE ~/img/img

# array i 
i=0

if [ -e "$LOGFILE" ] 
then
	while read TAG CONTENT
	do
		if [ "$TAG" = "commit"  ] 
		then
			if [ "$CONTENT" = "$LAST_TAG" ]
			then
				echo "commit $CONTENT"
				echo "find now ....i=$i"
				break
			else
				arrCommit[i]=$CONTENT

				let i++	
			fi
		fi
	
		if [ "$TAG" = "Author:" ]
		then 
			arrAuthor[i-1]=$CONTENT
		fi

		if [ "$TAG" = "Date:" ]
		then
			arrDate[i-1]=$CONTENT
		fi
					
	done < $LOGFILE

else
	echo "error"
fi

# print array
lenarrCommit=${#arrCommit[*]}
echo "Have $lenarrCommit version(s) need to compiled"

for ((i=0; i<lenarrCommit; i++));
do
		j=lenarrCommit-i-1
		#name
		tmp=`echo ${arrCommit[j]:0:7}`
		name=`echo "$tmp-"`
		tmp=`echo "${arrAuthor[$j]}" |awk '{print $1}'`
		name=`echo "$name$tmp-"`
		tmp=`echo "${arrDate[$j]}" |sed 's/ //1'|sed 's/ //1'|sed 's/ /-/'|sed 's/://g'|sed 's/ /-/'`
		name=`echo "$name$tmp"`
		echo "name==$name "

		#prepare comiple
		git checkout ${arrCommit[j]} 
		make clobber
		make -j4 
		if [ "$?" -eq "0" ]
		then
			echo "good"	
			outDir="out/target/product/maguro/"
			detDir=`echo "$name/"`
			zipName=`echo "$name.zip"`
			if [ -d detDir ]
			then
			#	echo "aaa"
				rm -rvf $detDir
			fi
			mkdir -p $detDir

			arrImg="boot.img recovery.img system.img userdata.img android-info.txt"
			for loop in $arrImg
			do
				cp $outDir$loop $detDir
			done
			zip -r $zipName $detDir
			rm -rvf $detDir
			mv $zipName ~/img/img

		else
			echo "bad"
		fi

		#save the new version
		echo "${arrCommit[$j] }" > $LAST
done

if [  "$lenarrCommit" -eq "0" ]
then
	echo "No newer commit yet. "
else
	cp $LOGFILE ~/img/img
	git checkout master
#	make -j4
#	echo "Have $lenarrCommit version(s) been compiled"
fi



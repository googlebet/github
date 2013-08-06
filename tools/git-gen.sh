#!/bin/bash

#for generate gits from source code

function is_empty_dir()
{
	local is_empty=0

	if [ $# -lt 1 ]
	then
		echo "error, no parameter"
		echo "for example, is_empty_dir xx_dir"
		return 1
	fi
	
	echo "param dir: $1"

	case $(find $1 2>&- |head -2 |wc -l) in
	0) echo "Permission deniend"
		return 0
		;;
	1) echo "Directory is empty"
		return 1
		;;
	2) echo "Directory is not empty"
		return 0
		;;
	esac

}


#A="ss.git"
#B=".git"
#C=`echo ${A%.git}`
#echo $C

REP="replog"
if [ -e $REP ]
then
	rm -f $REP
fi

LOG="log"
find . -name ".git" >$LOG
find . -name ".gitignore" |xargs rm -vf

RESULT="default.xml"
if [ -e $RESULT ]
then
	rm -f $RESULT
fi

DESTNAME="/home/tt/CyanogenMod/"

ROOTDIR=`pwd`

function delete_dir()
{
	if [ -d $DESTNAME ]
	then 
		rm -rvf $DESTNAME
	fi

	return 0
}

#delte dir
delete_dir

#create header
echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" >> $RESULT
echo "<manifest>" >> $RESULT

echo -e "\t<remote name=\"origin\"  fetch=\"ssh://git@codes/\" />" >> $RESULT
echo -e "\t<default revision=\"master\"  remote=\"origin\" sync-j=\"4\"  />" >> $RESULT
echo "" >> $RESULT

#build the loop
if [ -e "$LOG" ] 
then
	while read Line
	do
		#get git name and git dir
		GITDIR=`echo ${Line%/.git}`
		GITDIR=`echo ${GITDIR#./}`
		echo "git path $GITDIR"
		GITNAME=`echo ${GITDIR##*/}`
		echo "git name $GITNAME"
		echo -e "\t$GITDIR" >>$REP
		echo -e "\t<project path=\"$GITDIR\"  name=\"CyanogenMod/$GITDIR\" />" >> $RESULT
		
		#go to git dir
		if [ -d "$GITDIR" ]
		then
			cd $GITDIR
        #remove the git file
            if [ -d ".git" ]
            then
				 rm -rvf .git
	        fi

		#if it is empty, we need to touch ".gitignore"	
		#for avoid error while git clone a empty git repository
			is_empty_dir "./" 
			
			if [ $? -eq "1" ]
			then
				echo "++++++++++++++++++++++"
			touch .gitignore
			fi

        #init git create git respositroy
           	git init
            git add .
            git commit -am "init"
			cd ..

			DESTGIT=`echo "$DESTNAME$GITDIR.git"`
			echo "$GITNAME ---> $DESTGIT"
			git clone --bare "$GITNAME" $DESTGIT

		#delete the git name
			rm -rvf $GITNAME

		fi
		#back the current dir
		cd $ROOTDIR
#		pwd
	

	done < $LOG

#create tail
	echo "</manifest>" >> $RESULT
	cat $RESULT 

else
	echo "no log file"
fi

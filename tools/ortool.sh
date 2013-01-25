#!/bin/bash
echo "go now"
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

RESULT="manifest"
if [ -e $RESULT ]
then
	rm -f $RESULT
fi

DESTNAME="/home/tt/oor/"
ROOTDIR=`pwd`
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
		echo -e "\togt/$GITDIR" >>$REP
		echo "<project path=\"or_android/$GITDIR\"  name=\"oor/$GITDIR\" />" >> $RESULT

		
		#go to git dir
		if [ -d "$GITDIR" ]
		then
			cd $GITDIR
                        #remove the git file
                        if [ -d ".git" ]
	                then
				 rm -rvf .git
		        fi
	                #init git
                	git init
                        git add .
                        git commit -am "init"
			cd ..

			DESTGIT=`echo "$DESTNAME$GITDIR.git"`
			echo "$GITNAME --- $DESTGIT"
			git clone --bare "$GITNAME" $DESTGIT
			
			#delete the git name
			rm -rvf $GITNAME

		fi
		#back the current dir
		cd $ROOTDIR
#		pwd
	

	done < $LOG
	cat $RESULT 
else
	echo "no log file"
fi

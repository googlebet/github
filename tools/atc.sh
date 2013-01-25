#!/bin/bash -l

ROOT_DIR="/home/tt/work/"
repo_tool="/home/tt/bin/250repo"

LOGFILE="git.log"
LAST="last.log"

PLAT_LIST="or gt"

user="apa"
host="10.11.14.250"
dest_dir="/work/htdocs/img"


PRO_PATH="./ \
			./packages/apps/XingMuTTS/ \
			./packages/inputmethods/PinyinIME/ \
			./packages/apps/BillBoard/ \
			./packages/apps/CommonlyUsedDialpad/ \
			./packages/apps/SystemUpdate/ \
			./packages/apps/XingMuTTS/ \
			./packages/apps/Timer/ \
			./packages/apps/VoiceBack/ \
			./packages/apps/DigitalClock/ "

function reset_last_tag()
{
	local i=0
	local loop
	local last_log

	for loop in $PRO_PATH
	do
		last_log=$ROOT_DIR$1"/$1_android/"$loop$LAST
		echo "$last_log"

		if [ -e $last_log ]	
		then
#			echo "good we have one"
			arrLastTag[i]=`cat $last_log`
		else
			arrLastTag[i]="0000"
#			echo "no last tag yet"
		fi
		echo ${arrLastTag[i]}
		let i++
	done

}

function delete_git_log()
{
	local loop
	local git_log

	for loop in $PRO_PATH
	do
		git_log=$ROOT_DIR$1"/$1_android/"$loop$LOGFILE
		if [ -e $git_log ]
		then
#			echo $git_log
			rm -rvf $git_log
		fi
	done	
}

function update_repo()
{
	local repo_path 

	repo_path=$ROOT_DIR$loop"/"
#	echo $repo_path
# enter in the project directory
	if [ -d $repo_path  ]
	then
		cd $repo_path
		$repo_tool sync
		
		if [ "$?" -eq "0" ]
		then
		    echo "repo sync code is OK."
			
		fi
	fi
}

function is_new_repo()
{
#not ok now
	return 1
}

function compile_repo()
{
	local plat_path=$ROOT_DIR$1"/$1_android/"
	
	echo $plat_path
	if [ -d $palt_path ]
	then
		cd $plat_path

#setup build environment
		. $plat_path"build/envsetup.sh"
		echo "Going to build $1 project"

		case $1 in
		or)	lunch full_maguro-userdebug
		;;
		gt)	choosecombo 1 22 2
		;;
		esac
#ok build project
		/usr/bin/make clean
		/usr/bin/make -j8
		return $?
	fi

	return 1 
}

function package_img_files()
{
	local zip_name=`date +%H%M%S-%Y%m%d-`$1"-imgs"".zip"
	local img_path
	
#	echo $ROOT_DIR$1"/$1_android/out/target/product/maguro/"

	case $1 in
	or) echo "in or project"
		img_path=`echo $ROOT_DIR$1"/$1_android/out/target/product/maguro/"`
	;;
	gt) echo "in gt project"
		img_path=`echo $ROOT_DIR$1"/$1_android/out/target/product/msm8625/"`
	;;
	esac	
		
	echo $zip_name
	echo $img_path

	if [ -d $img_path  ]
	then
		cd $img_path
		pwd
		if [ -e $zip_name  ]
		then
			/bin/rm -rvf $zip_name
		fi
#get zip file
		/usr/bin/zip -0 $zip_name system.img userdata.img
		if [ $? -eq "0" ]
		then
#			/bin/mv $zip_name /home/tt/img/img/ 
#			/home/tt/bin/scpfile.exp $zip_name

			/usr/bin/scp $zip_name $user@$host:$dest_dir
			/bin/rm -vf $zip_name
		fi
	fi
}

#main program 
for loop in $PLAT_LIST
do
#	echo $ROOT_DIR$loop

	#clear last.log information
#	reset_last_tag $loop
#	delete_git_log $loop

	update_repo $loop
	is_new_repo	$loop
	
	if [ "$?" -eq "1" ]
then
		echo "Get new version"
		compile_repo $loop	
		
#package img files
		if [ "$?" -eq "0"  ]
		then
			package_img_files $loop
		else
			echo "Big compile error......................"
		fi

	fi	

done






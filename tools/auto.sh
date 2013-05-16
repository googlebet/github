#!/bin/bash -l

ROOT_DIR="/home/tt/work/"
repo_tool="/home/tt/bin/250repo"

LOGFILE="git.log"
LAST="last.log"

PLAT_LIST="gt or"
branches="xm1.2.0"
remote_server="origin/"
FETCH_LOG="/home/tt/bin/fetch.log"

user="apa"
host="codes"
dest_dir="/work/htdocs/img"


function switch2branch()
{
	local local_br=$2
	local remote_br=$remote_server"$2"
	local repo_path=$ROOT_DIR$1"/"
	
	echo "repo path $repo_path"
	echo "switch to local  $local_br $remote_br"
	
	#checkout the branch we needed
	if [ -d $repo_path  ]
	then
	    cd $repo_path
	    $repo_tool forall -c git checkout $remote_br

	    if [ "$?" -eq "0" ]
	    then
    	    echo "repo sync code is OK."

	    fi
	fi

}

function update_repo()
{
	local repo_path 

	repo_path=$ROOT_DIR$1"/"
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

function fetch_repo()
{
    local repo_path=$ROOT_DIR$1"/"

    echo $repo_path

# enter in the project directory
    if [ -d $repo_path  ]
    then
        cd $repo_path
        $repo_tool forall -c 'git fetch'

        if [ "$?" -eq "0" ]
        then
            echo "repo fetch code is OK."

        fi
    fi
}

function is_new_repo()
 {
      local log_size
      local repo_path
      local local_br=$2
      local remote_br=$remote_server"$2"
      local repo_path=$ROOT_DIR$1"/"

      echo $repo_path

  # enter in the project directory
      if [ -d $repo_path  ]
      then
          cd $repo_path
 #       $repo_tool forall -c git cherry $BUILD_BR $UP_BR |/usr/bin/tee  $FETCH_LOG

		  $repo_tool start $local_br --all
          $repo_tool forall -c git cherry $local_br $remote_br |/usr/bin/tee $FETCH_LOG

         if [ -e $FETCH_LOG ]
         then
             log_size=`ls -l $FETCH_LOG|/usr/bin/awk '{print $5}'`
             echo "log_size "$log_size""

             if [ "$log_size" -eq "0" ]
             then
                 echo "No more commits, do not need to compile"
                 return 0
             else
                 /bin/cat $FETCH_LOG
                 echo "Get new version 00"
                 return 1
             fi
         fi
      fi

     echo "No more commits, not need to compile"

     return 0
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
	local zip_name=`date +%H%M%S-%Y%m%d-`"$1-$2""-imgs"".zip"
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
		/usr/bin/zip -0 $zip_name system.img userdata.img boot.img
		if [ $? -eq "0" ]
		then
#			/home/tt/bin/scpfile.exp $zip_name

			/usr/bin/scp $zip_name $user@$host:$dest_dir
			/bin/rm -vf $zip_name
		fi
	fi
}

function new_for_test()
{
	echo "new"
	return 1
}

function sign_apk()
{
     local plat_path=$ROOT_DIR$1"/$1_android/"

     echo $plat_path
     if [ -d $plat_path ]
     then
         cd $plat_path
         pwd
         ./build.sh
     fi

 }

#main program 
for loop in $PLAT_LIST
do

	for loop1 in $branches
	do
		echo $ROOT_DIR$loop
		echo "in $loop1 branch"

#		fetch_repo $loop
		#test only
		new_for_test
#		is_new_repo	$loop $loop1
	
		if [ "$?" -eq "1" ]
		then
			echo "Get new version,get latest source code"
			update_repo $loop

		#	switch2branch $loop $loop1
		#	sign_apk $loop
			compile_repo $loop	
		
	#package img files
			if [ "$?" -eq "0"  ]
			then
				echo "package img files"
				package_img_files $loop $loop1
			else
				echo "Big compile error......................"
			fi

		fi	
	done

done


#!/bin/bash

user="apa"
host="codes"
dest_dir="/work/htdocs/apk_release"

function usage()
{	
	echo "copy file to codes:/work/htdocs/apk_release"
	echo "usage: `basename $0` file1,file2,file3,..."
	return 0
}

function copyfile()
{
	/usr/bin/scp $1 $user@$host:$dest_dir
	
	return 0
}

if [ $# -lt 1 ]
then
	usage
	exit 1
fi

loop=0
while [ $# -ne 0 ]
do
	copyfile $1
	shift
done


#!/bin/sh

# Copyright (C) 2011 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


echo $1
if [ "$1" = "system.img" ] || [ "$1" = "userdata.img" ]
then
	echo "flash $1 now ...."
	img=`echo $1|sed 's/.img//'`
	echo "img=$img"
    adb reboot bootloader
    sleep 5
    fastboot reboot-bootloader
    sleep 5
	fastboot flash -w boot boot.img
	fastboot flash $img $1
	fastboot reboot
elif [ "$1" = "all" ]
	 then
		echo "flash all...."
		adb reboot bootloader
		sleep 5
		fastboot reboot-bootloader
		sleep 5
		fastboot flash -w boot boot.img
		fastboot flash system system.img
		fastboot flash userdata userdata.img
		fastboot reboot
else
		echo "error, no $1 option"
		echo "for example............"
		echo "flash-img.sh system.img"
		echo "flash-img.sh userdata.img"
		echo "flash-img.sh all"
fi

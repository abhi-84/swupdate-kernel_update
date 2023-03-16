#!/bin/bash


if [ $# -lt 1 ]; then
	exit 0;
fi

function reboot
{
	echo "Rebooting U54 Board"
	echo 506 > /sys/class/gpio/export
	cd /sys/class/gpio/gpio506
	sleep 5
	echo in > direction
	sleep 5
	echo out > direction
	sleep 5

}

function check_version
{
	for i in `cat /etc/sw-versions`; do
        	currentver="${i:0:21}"
	done

	echo "current version $currentver"

	updatever="5.10.19"
	if [ "$(printf '%s\n' "$updatever" "$currentver" | sort -V | head -n1)" = "$updatever" ]; then
        	echo "Greater than or equal to ${currentver}; no reboot required"
		#exit 1;
	else
        	echo "Less than ${currentver}"
		#reboot
		
	fi
 
}

function current_kernel_path
{
        for i in `fw_printenv distro_bootpart`; do
                if [ ${i:0:16} = "distro_bootpart=" ]; then

                        KERNEL_PATH="${i:16}"
                fi
        done
}

if [ $1 == "preinst" ]; then
	# mount kernel partition
	current_kernel_path	
	if [ $KERNEL_PATH = "1" ]; then
		mount /dev/mmcblk0p2 /mnt
	else
		mount /dev/mmcblk0p1 /mnt
	fi
	#echo "kernel_update 5.10.19" > /etc/sw-versions
	#check_version

fi

if [ $1 == "postinst" ]; then 
	current_kernel_path
	if [ $KERNEL_PATH = "1" ]; then
		fw_setenv distro_bootpart 2
	else
		fw_setenv distro_bootpart 1
	fi
	#previous_working_kernel 1
	echo "kernel_update 5.10.19" > /etc/sw-versions
	#update kernel version in sw-versions file
	sleep 5	
	#check_version
	reboot
fi




#systemctl restart swupdate

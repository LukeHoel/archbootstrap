#!/bin/sh

# Device to install on, fill in manually, then remove exit 1
installDevice=

# Set date time, to be assembled in format MMDDhhmmyyyy
month=""
day=""
hour=""
minute=""
year=""
stage3Url=""
# System config
timeZone="America/Toronto"
localeGen="en_US.UTF-8 UTF-8"
localeConf="LANG=en_US.UTF-8"
hostName="archlinux"
extraPackages="base-devel git vim"

# Remove this after you've set everything up how you want it
exit 1

read -p "Proceed with installation? This will wipe the device $installDevice (yn) : " REPLY
if [[ $REPLY =~ ^[Yy]$ ]]
then
		#
		# System setup
		#

		# Wipe the device
		dd bs=512 count=1 if=/dev/zero of=$installDevice
		
		echo "	select $installDevice
				mklabel gpt
				mkpart primary 0% 512
				mkpart primary 512 100%
				set 1 bios_grub on" | parted

		bootPartition="${installDevice}1"
		rootPartition="${installDevice}2"

		# Init partitions
		yes | mkfs.fat $bootPartition
		yes | mkfs.ext4 $rootPartition

		# Mount partitions
		mount $rootPartition /mnt
		mount $bootPartition /mnt/boot
		
		#
		# Follow the steps from the install gentoo wiki
		#
		date "$month$day$hour$minute$year"
		cd /mnt/gentoo
		curl "$stage3Url" >> stage3.tar.xz
		sha512sumValue=$(sha512sum stage3.tar.xz)
		tar xpvf stage3.tar.xz --xattrs-include='*.*' --numeric-owner
		genfstab -U /mnt >> /mnt/etc/fstab
			
		# Run remaining commands under chroot
		#arch-chroot /mnt /bin/bash -c "ln -sf /usr/share/zoneinfo/$timeZone /etc/localtime;
		#hwclock --systohc;
		#echo $localeGen > /etc/locale.gen;
		#echo $localeConf > /etc/locale.conf;
		#echo $hostName > /etc/hostname;	
		#printf \"127.0.0.1 localhost\n::1 localhost\n127.0.1.1 $hostName.localdomain $hostName\" > /etc/hosts;
		#grub-install --target=i386-pc $installDevice;
		#grub-mkconfig -o /boot/grub/grub.cfg;"

		# Output some important information
		echo
		printf "***\nInstall Complete\n***";
		echo
		echo "The sha512sum result of the stage 3 tarball was: "
		printf "\t$sha512sumValue"
fi 



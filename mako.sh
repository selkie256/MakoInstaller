timedatectl set-ntp true
fdisk -l
echo "Welches Gerät soll verwendet werden?"
read DEVICE
if [ -b !$DEVICE ];
then
	while [ -b !$DEVICE ];
	do
		fdisk -l
		echo "Das Gerät existiert nicht! Bitte geben Sie es noch einmal an!"
		read DEVICE
	done
fi
fdisk $DEVICE
echo "Bitte geben Sie die EFI-Partition an!"
read EFIPART
if [ -b !$EFIPART ];
then
	while [ -b !$EFIPART ];
	do
		fdisk -l
		echo "Diese Partition existiert nicht! Bitte geben Sie sie noch einmal an!"
		read EFIPART
	done
fi
mkfs.fat -F 32 $EFIPART
echo "Bitte geben Sie die Root-Partition an!"
read ROOTPART
if [ -b !$ROOTPART ];
then
	while [ -b !$ROOTPART ];
	do
		fdisk -l
		echo "Diese Partition existiert nicht! Bitte geben Sie sie noch einmal an!"
		read ROOTPART
	done
fi
mkfs.ext4 $ROOTPART
echo "Haben Sie eine Home-Partition erstellt? J oder N eingeben!"
read ANSWER
if [ $ANSWER = "J" ];
then
	echo "Bitte geben Sie die Home-Partition an!"
	read HOMEPART
	if [ -b !$HOMEPART ];
	then
		while [ -b !$HOMEPART ];
		do
			fdisk -l
			echo "Diese Partition existiert nicht! Bitte geben Sie sie noch einmal an!"
			read HOMEPART
		done
	fi
mkfs.ext4 $HOMEPART
fi
echo "Haben Sie eine Swap-Partition erstellt? J oder N eingeben!"
read ANSWER
if [ $ANSWER = J ];
then
	echo "Bitte geben Sie die Swap-Partition an!"
	read SWAPPART
	if [ -b !$SWAPPART ];
	then
		while [ -b !$SWAPPART ];
		do
			fdisk -l
			echo "Diese Partition existiert nicht! Bitte geben Sie sie noch einmal an!"
			read SWAPPART
		done
	fi
	mkswap $SWAPPART
fi
mount $ROOTPART /mnt
if [ -b $HOMEPART];
then
	mkdir /mnt/home
fi
mkdir /mnt/boot
mkdir /mnt/boot/efi
if [ -b $SWAPPART ];
then
	swapon $SWAPPART
fi
pacstrap /mnt base linux linux-firmware base-devel efibootmgr grub plasma-meta kde-applications libreoffice-fresh-de thunderbird vlc sddm nano sudo supertuxkart sauerbraten sauerbraten-data intel-ucode mesa wayland plasma-wayland-session kodi supertux codeblocks
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./postinstall.sh

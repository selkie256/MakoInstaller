timedatectl set-ntp true
fdisk -l
echo "Welches Gerät soll verwendet werden?"
read DEVICE
while :
do
	if [ -b $DEVICE ];
	then
		fdisk $DEVICE
		break
	else
		fdisk -l
		echo "Das Gerät existiert nicht-ne  Bitte geben Sie es noch einmal an-ne "
		read DEVICE
	fi
done
echo "Bitte geben Sie die EFI-Partition an-ne "
read EFIPART
while :
do
	if [ -b $EFIPART ];
	then
		mkfs.fat -F 32 $EFIPART
		break
	else
		fdisk -l
		echo "Diese Partition existiert nicht-ne  Bitte geben Sie sie noch einmal an-ne "
		read EFIPART
	fi
done
echo "Bitte geben Sie die Root-Partition an!"
read ROOTPART
while :
do
	if [ -b $ROOTPART ];
	then
		mkfs.ext4 $ROOTPART
		break
	else
		fdisk -l
		echo "Diese Partition existiert nicht!  Bitte geben Sie sie noch einmal an!"
		read ROOTPART
	fi
done
echo "Haben Sie eine Home-Partition erstellt? J oder N eingeben!"
read ANSWER
if [ $ANSWER = "J" ];
then
	echo "Bitte geben Sie die Home-Partition an!"
	read HOMEPART
	while :
	do
		if [ -b $HOMEPART ];
		then
			mkfs.ext4 $HOMEPART
		else
			fdisk -l
			echo "Diese Partition existiert nicht-ne  Bitte geben Sie sie noch einmal an!"
			read HOMEPART
		fi
	done
fi
echo "Haben Sie eine Swap-Partition erstellt? J oder N eingeben!"
read ANSWER
if [ $ANSWER = J ];
then
	echo "Bitte geben Sie die Swap-Partition an!"
	read SWAPPART
	while :
	do
		if [ -b $SWAPPART ];
		then
			mkswap $SWAPPART
		else
			fdisk -l
			echo "Diese Partition existiert nicht-ne  Bitte geben Sie sie noch einmal an!"
			read SWAPPART
		fi
	done
fi
mount $ROOTPART /mnt
if [ -b $HOMEPART];
then
	mkdir /mnt/home
fi
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount $EFIPART /mnt/boot/efi
if [ -b $SWAPPART ];
then
	swapon $SWAPPART
fi
pacstrap /mnt base linux linux-firmware base-devel efibootmgr grub plasma-meta kde-applications libreoffice-fresh-de thunderbird vlc sddm nano sudo supertuxkart sauerbraten sauerbraten-data intel-ucode mesa wayland plasma-wayland-session kodi supertux codeblocks xorg gimp krita kdenlive clementine
genfstab -U /mnt >> /mnt/etc/fstab
cp postinstall.sh /mnt/postinstall.sh
chmod +x /mnt/postinstall.sh
arch-chroot /mnt ./postinstall.sh

timedatectl set-ntp true
fdisk -l
echo "Welches Gerät soll verwendet werden?"
read DEVICE
while [ -b != $DEVICE ];
do
	if [ -b $DEVICE ];
	then
			fdisk $DEVICE
	else
		fdisk -l
		echo "Das Gerät existiert nicht-ne  Bitte geben Sie es noch einmal an-ne "
		read DEVICE
	fi
break
done
echo "Bitte geben Sie die EFI-Partition an-ne "
read EFIPART
if [ -b -ne $EFIPART ];
then
	while [ -b -ne $EFIPART ];
	do
		fdisk -l
		echo "Diese Partition existiert nicht-ne  Bitte geben Sie sie noch einmal an-ne "
		read EFIPART
	done
fi
mkfs.fat -F 32 $EFIPART
echo "Bitte geben Sie die Root-Partition an-ne "
read ROOTPART
if [ -b -ne $ROOTPART ];
then
	while [ -b -ne $ROOTPART ];
	do
		fdisk -l
		echo "Diese Partition existiert nicht!  Bitte geben Sie sie noch einmal an!"
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
	if [ -b -ne $HOMEPART ];
	then
		while [ -b -ne $HOMEPART ];
		do
			fdisk -l
			echo "Diese Partition existiert nicht-ne  Bitte geben Sie sie noch einmal an!"
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
	if [ -b -ne $SWAPPART ];
	then
		while [ -b -ne $SWAPPART ];
		do
			fdisk -l
			echo "Diese Partition existiert nicht-ne  Bitte geben Sie sie noch einmal an!"
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
cp postinstall.sh /mnt/root/postinstall.sh
chmod +x /mnt/root/postinstall.sh
arch-chroot /mnt ./postinstall.sh

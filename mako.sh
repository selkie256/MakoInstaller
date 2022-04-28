contains_element() { #{{{
	#check if an element exist in a string
	for e in "${@:2}"; do [[ "$e" == "$1" ]] && break; done
}                  #}}}
#select keymap
keymap_list=($(find /usr/share/kbd/keymaps/ -type f -printf "%f\n" | sort -V | sed 's/.map.gz//g'))
PS3="Bitte geben Sie das Tastaturlayout ein!"
select KEYMAP in "${keymap_list[@]}";
do
	if contains_element "$KEYMAP" "${keymap_list[@]}";
	then
		echo "$KEYMAP"
		loadkeys $KEYMAP
		break
	else
		echo "Dieses Tastatur-Layout existiert nicht!"
		echo $KEYMAP
	fi
done
timedatectl set-ntp true
#create partitions
devices_list=($(lsblk -d | awk '{print "/dev/" $1}' | grep 'sd\|hd\|vd\|nvme\|mmcblk'))
PS3="$prompt1"
echo -e "Attached Devices:\n"
lsblk -lnp -I 2,3,8,9,22,34,56,57,58,65,66,67,68,69,70,71,72,91,128,129,130,131,132,133,134,135,259 | awk '{print $1,$4,$6,$7}' | column -t
echo -e "\n"
echo -e "Select device to partition:\n"
select device in "${devices_list[@]}";
do
	if contains_element "${device}" "${devices_list[@]}";
	then
		fdisk $device
		break
	else
		echo "Das Gerät existiert nicht!"
	fi
done
#select EFI partition
partitions_list=($(lsblk -lnp "$device" | grep 'part' | awk '{print $1}' | grep 'sd\|hd\|vd\|nvme\|mmcbl' ))
PS3="$prompt1"
echo -e "Verfügbare Partitionen:\n"
lsblk -lnp "$device" | awk '{print $1,$4,$6,$7}' | column -t
echo -e "\n"
echo -e "Bitte wählen Sie die EFI-Partition aus"
select EFIPART in "${partitions_list[@]}";
do
	if contains_element "${EFIPART}" "${partitions_list[@]}";
	then
		mkfs.vfat $EFIPART
	else
		echo "Diese Partition existiert nicht!"
	fi
done
#select root partition
partitions_list=($(lsblk -lnp "$device" | grep 'part' | awk '{print $1}' | grep 'sd\|hd\|vd\|nvme\|mmcbl' ))
PS3="$prompt1"
echo -e "Verfügbare Partitionen:\n"
lsblk -lnp "$device" | awk '{print $1,$4,$6,$7}' | column -t
echo -e "\n"
echo -e "Bitte wählen Sie die Root-Partition aus"
select ROOTPART in "${partitions_list[@]}";
do
	if contains_element "${ROOTPART}" "${partitions_list[@]}";
	then
		mkfs.ext4 $ROOTPART
	else
		echo "Diese Partition existiert nicht!"
	fi
done
#select home partition
echo "Haben Sie eine Home-Partition erstellt? J oder N eingeben!"
read ANSWER
if [ $ANSWER = "J" ];
then
	partitions_list=($(lsblk -lnp "$device" | grep 'part' | awk '{print $1}' | grep 'sd\|hd\|vd\|nvme\|mmcbl' ))
	PS3="$prompt1"
	echo -e "Verfügbare Partitionen:\n"
	lsblk -lnp "$device" | awk '{print $1,$4,$6,$7}' | column -t
	echo -e "\n"
	echo -e "Bitte wählen Sie die Home-Partition aus"
	select SHOMEPART in "${partitions_list[@]}";
	do
		if contains_element "${HOMEPART}" "${partitions_list[@]}";
		then
			mkfs.ext4 $HOMEPART
		else
			echo "Diese Partition existiert nicht!"
		fi
	done
fi
#select swap partition
echo "Haben Sie eine Swap-Partition erstellt? J oder N eingeben!"
read ANSWER
if [ $ANSWER = J ];
then
	partitions_list=($(lsblk -lnp "$device" | grep 'part' | awk '{print $1}' | grep 'sd\|hd\|vd\|nvme\|mmcbl' ))
	PS3="$prompt1"
	echo -e "Verfügbare Partitionen:\n"
	lsblk -lnp "$device" | awk '{print $1,$4,$6,$7}' | column -t
	echo -e "\n"
	echo -e "Bitte wählen Sie die Swap-Partition aus"
	select SWAPPART in "${partitions_list[@]}";
	do
		if contains_element "${SWAPPART}" "${partitions_list[@]}";
		then
			mkswap $SWAPPART
		else
			echo "Diese Partition existiert nicht!"
		fi
	done
#mout partitions
mount $ROOTPART /mnt
if [ -b $HOMEPART];
then
	mkdir /mnt/home
	mount $HOMEPART /mnt/home
fi
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount $EFIPART /mnt/boot/efi
if [ -b $SWAPPART ];
then
	swapon $SWAPPART
fi
#install base system
pacstrap /mnt base linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
#copy post install script to new root
cp postinstall.sh /mnt/postinstall.sh
chmod +x /mnt/postinstall.sh
arch-chroot /mnt ./postinstall.sh
#reboot after chroot
echo "Die Installation ist abgeschlossen!"
echo "Wollen Sie jetzt neu starten?"
read ANSWER
if [ $ANSWER = "J"];
then
	reboot
fi

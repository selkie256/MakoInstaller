echo "Bitte geben Sie ihre Zeitzone an! Z. B. Europe/Berlin"
read TIMEZONE
if [ -b /usr/share/zoneinfo/!$TIMEZONE ];
then
	while [ -f /usr/share/zoneinfo/$TIMEZONE ];
	do
		echo "Diese Zeitzone existiert nicht! Bitte geben Sie sie noch einmal ein!"
		read TIMEZONE
	done
fi
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
echo "de_DE.UTF8" >> /etc/locale.gen
locale-gen
echo "LANG=de_DE.UTF-8" >> /etc/locale.conf
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "Geben Sie einen Host-Namen an!"
read HOSTNAME
echo $HOSTNAME >> /etc/hostname
mkinitcpio -P
passwd
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Mermaidia OS"
grub-mkconfig -o /boot/grub/grub.cfg
echo "Bitte geben Sie einen Benutzernamen für Ihren Benutzer ein!"
read USERNAME
useradd -m -G video,audio,storage,floppy,ftp,http,games,disk,kvm,network,scanner $USERNAME

echo "Bitte geben Sie ihre Zeitzone an! Z. B. Europe/Berlin"
read TIMEZONE
while :
do
	if [ -f /usr/share/zoneinfo/$TIMEZONE ];
	then
		ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
		break
	else
		echo "Diese Zeitzone existiert nicht! Bitte geben Sie sie noch einmal ein!"
		read TIMEZONE
	fi
done
hwclock --systohc
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=de_DE.UTF-8" >> /etc/locale.conf
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "Geben Sie einen Host-Namen an!"
read HOSTNAME
echo $HOSTNAME >> /etc/hostname
mkinitcpio -P
echo "Bitte geben Sie das Passwort für den Root-Benutzer ein!"
passwd
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Mermaidia OS"
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable sddm
systemctl enable NetworkManager
echo "Bitte geben Sie einen Benutzernamen für Ihren Benutzer ein!"
read USERNAME
useradd -m -G video,audio,storage,floppy,ftp,http,games,disk,kvm,network,scanner $USERNAME
echo "Bitte geben Sie ein Passwort für $USERNAME ein!"
passwd $USERNAME
echo "Die Installation ist abgeschlossen!"
echo "Wollen Sie jetzt neu starten?"
read ANSWER
if [ $ANSWER = "J"];
then
	exit
	reboot
fi

# find latest iso http://download.virtualbox.org/virtualbox/4.3.30/
wget http://download.virtualbox.org/virtualbox/4.3.30/VBoxGuestAdditions_4.3.30.iso
mkdir -p /mnt/iso
mount -t iso9660 -o loop VBoxGuestAdditions_4.3.30.iso /mnt/iso
cd /mnt/iso
./VBoxLinuxAdditions.run
cd
umount /mnt/iso

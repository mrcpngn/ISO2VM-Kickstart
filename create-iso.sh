#!/bin/bash

# Before you start please install the following packages:
# sudo apt install genisoimage syslinux-utils isomd5sum -y

DIR=$(pwd)

# 1. Create a folder and mount the iso file
mkdir raw-iso
mount -o loop $1 raw-iso

# 2. Create a temp iso directory annd copy all the contents including the kickstart file.
mkdir temp-iso
shopt -s dotglob 
cp -avRf raw-iso/* temp-iso
cp $2 temp-iso/

LABEL=$(blkid $1 | awk '{print $3}' | awk -F'"' '{$0=$2}1')

# 3. Modify the configuration files
sed -i -e 's/600/100/g' temp-iso/isolinux/isolinux.cfg
sed -i '/menu default/d' temp-iso/isolinux/isolinux.cfg

cat <<EOF > ks-temp.txt
label kickstart 
  menu label ^Install via Kickstart
  menu default 
  kernel vmlinuz append initrd=initrd.img inst.stage2=hd:LABEL=$LABEL inst.ks=cdrom:/$2

EOF
sed -i -e $'/\label linux/{e cat     ks-temp.txt\n}' temp-iso/isolinux/isolinux.cfg
rm -rf ks-temp.txt

cat <<EOF > grub-temp.txt
menuentry 'Install via Kickstart' --class fedora --class gnu-linux --class gnu --class os {
	linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=$LABEL quiet inst.ks=cdrom:/$2
	initrdefi /images/pxeboot/initrd.img
}

EOF
sed -i -e $'/submenu/{e cat     grub-temp.txt\n}' temp-iso/EFI/BOOT/grub.cfg
rm -rf grub-temp.txt 

4. Create the custom iso file
cd ./temp-iso && mkisofs -joliet-long -o $DIR/$3.iso -b isolinux/isolinux.bin -J -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -V "$LABEL" . && isohybrid --uefi $DIR/$3.iso && implantisomd5 $DIR/$3.iso


# Clean up and unmount the iso
umount $DIR/raw-iso
rm -rf $DIR/temp-iso
rm -rf $DIR/raw-iso

# This is for WSL test only
# Transfer the files on windows dekstop
# cp -rf $DIR/$3.iso /mnt/c/Users/admin/Desktop/customiso/linux/$3.iso
# rm -rf $DIR/$3.iso

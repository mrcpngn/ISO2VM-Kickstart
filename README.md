# Automate Linux ISO Installation

About: 
This script will automatically create a Linux custom ISO file.
For now the script is tested on Debian-based distros.

Things to note:
1. Before you start you must install the following packages:
    - genisoimage
    - syslinux-utils
    - isomd5sum
2.  Please place the iso file and kickstart file with the same directory of the script.
3. The script must be run in Administrative privileges.
4. You must supply your own kickstart file and ISO file.
5. The script is setup in a WSL environment.

Syntax: 
./create-iso.sh \
[ISO_PATH] \
[Kickstart] \
[ISOFilename]

Sample:
sudo ./create-iso.sh \
AlmaLinux-8.5-x86_64-minimal.iso \
basic-kickstart.cfg \
Almalinux8.5-CustomISO-basic-ks

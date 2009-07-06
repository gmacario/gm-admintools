#!/bin/bash
# 20090706
# Andrea Sanna < andrea.sanna @ mmarelli-se.com >

VMNAME=ubuntu-build
PYTHON=/usr/bin/python
CONFDIR=vm_create_ubuntu_build_machine
UBUNTUDISC=/Users/andrea/Desktop/ubuntu-9.04-alternate-i386.iso
DISKSIZE=60G
QEMUIMG=qemu-img

function do_usage {
    echo "$0 <EXPORT-DIR> <UBUNTU-ISO-IMAGE>";
}

function do_clean_all {
    echo -n "Do you want to remove ${CONFDIR} ? [Y/N] "
    read ans;
    if [ "$ans" = "Y" ]; then
	rm -rf ${CONFDIR}
	mkdir ${CONFDIR} || exit -1
    else
	do_usage;
	exit -1
    fi;
}

function do_check {
    if [ ! -f  ${UBUNTUDISC} ]; then
	echo "[ERROR] - Ubuntu iso-image file not found";
	do_usage;
	exit -1
    fi

    if [ -d ${CONFDIR} ]; then
	echo "[ERROR] - ${CONFDIR} already exists."
	do_clean_all;
    else
	mkdir ${CONFDIR} || exit -1
    fi;
}

function do_create_ks {
    cat >> ${CONFDIR}/ks.cfg <<EOF
lang en_US
langsupport en_GB fr_FR it_IT --default=en_US
keyboard us
mouse
timezone America/New_York
rootpw --iscrypted $1$Rn4QJxGa$kJWNVEw57qkNBFoZUPxwn0
user user01 --fullname "Build User" --iscrypted --password $1$9.XzAhdx$wsrvQhs6PZ4wS8Xw3EqhY0
reboot
text
install
cdrom
bootloader --location=mbr 
zerombr yes
clearpart --all --initlabel 
part swap --size 1024 --ondisk sda 
part / --fstype reiserfs --size 1 --grow --ondisk sda 
auth  --useshadow  --enablemd5 
network --bootproto=dhcp --device=eth0
firewall --disabled 
xconfig --depth=32 --resolution=1024x768 --defaultdesktop=GNOME --startxonboot
EOF
}

function do_create_vmdk {
    ${QEMUIMG} create -f vmdk ${CONFDIR}/${VMNAME}.vmdk ${DISKSIZE} || exit -1
}

function do_create_vmx {
    cat > ${CONFDIR}/${VMNAME}.vmx <<EOF
config.version = "8"
virtualHW.version = "3"
ide0:0.present = "TRUE"
ide0:0.filename = "${VMNAME}.vmdk"
memsize = "128"
MemAllowAutoScaleDown = "FALSE"
ide1:0.present = "TRUE"
ide1:0.fileName = "${UBUNTUDISC}"
ide1:0.deviceType = "cdrom-image"
ide1:0.autodetect = "TRUE"
floppy0.present = "FALSE"
ethernet0.present = "TRUE"
usb.present = "TRUE"
sound.present = "TRUE"
sound.virtualDev = "es1371"
displayName = "${VMNAME}"
guestOS = "ubuntu"
nvram = "${VMNAME}.nvram"
MemTrimRate = "-1"
ide0:0.redo = ""
ethernet0.addressType = "generated"
uuid.location = "56 4d 5c cc 3d 4a 43 29-55 89 5c 28 1e 7e 06 58"
uuid.bios = "56 4d 5c cc 3d 4a 43 29-55 89 5c 28 1e 7e 06 58"
ethernet0.generatedAddress = "00:0c:29:7e:06:58"
ethernet0.generatedAddressOffset = "0"
tools.syncTime = "TRUE"
ide1:0.startConnected = "TRUE"
uuid.action = "create"
checkpoint.vmState = ""
EOF
}

function do_webserver_start {
    cd ${CONFDIR}
    ${PYTHON} -m SimpleHTTPServer 8282 &
    cd -
}

###### main #######

if [ $1 ]; then CONFDIR=$1; fi
if [ $2 ]; then UBUNTUDISC=$2; fi

clear;
do_check;
do_create_vmx;
do_create_vmdk;
do_webserver_start;

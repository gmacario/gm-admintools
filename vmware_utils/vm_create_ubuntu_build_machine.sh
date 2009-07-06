#!/bin/bash
# 20090706
# Andrea Sanna < andrea.sanna @ mmarelli-se.com >

VMNAME=ubuntu-build
CONFDIR=vm_ubuntu_create_build_machine/
UBUNTUDISC=/Users/andrea/Desktop/ubuntu-9.04-alternate-i386.iso
DISKSIZE=60G
QEMUIMG=qemu-img

function do_usage {
    echo "$0 <EXPORT-DIR> <UBUNTU-ISO-IMAGE>";
}


function do_check {
    if [ ! -f  ${UBUNTUDISC} ]; then
	echo "[ERROR] - Ubuntu iso-image file not found";
	exit -1
    fi

    if [ -d ${CONFDIR} ]; then
	echo "[ERROR] - ${CONFDIR} already exists."
    else
	mkdir ${CONFDIR} || exit -1
    fi;
}

function do_create_vmdk {
    ${QEMUIMG} create -f vmdk ${CONFDIR}/${VMNAME}.vmdk ${DISKSIZE} || exit -1
}

function do_create_vmx {
    cat > ${CONFDIR}/${VMNAME}.vmx <<EOF
#!/usr/bin/vmware
displayName = "£{VMNAME}"
guestOS = "ubuntu"
memsize = "512"
scsi0:0.fileName = "${VMNAME}.vmdk"
ide1:0.fileName = "${UBUNTUDISC}"
EOF
}


###### main #######

if [ $1 ]; then CONFDIR=$1; fi
if [ $2 ]; then UBUNTUDISC=$2; fi

do_check;
do_create_vmx;
do_create_vmdk;

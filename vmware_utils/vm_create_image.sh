#!/bin/sh
# =============================================================================
# Project:      LUPIN
#
# Description:	Create a new VMware VM from a .vmx template
#
# Language:     Linux Shell Script
#
# Usage example:
#       $ ./vm_create_image.sh
#
# The script attempts to fetch configuration options
# from a configuration file in the following search list:
#       * ./$confpattern.conf
#       * ${HOME}/.$confpattern/$confpattern.conf
#       * /etc/$confpattern.conf
#
# Package Dependencies:
#       Required:       awk cp fileutils sh tar
#       Optional:       samba
#
# Copyright 2007-2009 Magneti Marelli Electronic Systems - All Rights Reserved
# =============================================================================

# Configurable Parameters
#
# NOTE: The following configuration variables
#       may be overridden by do_create_vm.conf (see comments above)

#??? VM_BCKDIR=/var/tmp/Backup_VM
#VM_BCKDATE=20090201
#VM_OLDNAME=Ubuntu804-WR_PFIjan28

#VM_DESTDIR=${HOME}/tmp
VM_DESTDIR="/var/lib/vmware/Virtual Machines"
#
VM_NAME=Ubuntu904beta-test01
VM_TEMPLATE=samples/Ubuntu.vmx

VMRUN_SERVERTYPE=server
VMRUN_SERVERHOST=https://lupin01.venaria.marelli.it:8333/sdk
VMRUN_USER=macario
#VMRUN_PASS=xxxx

# -----------------------------------------------------------------------------
# You should not need to change the script below
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Main Program starts here
echo "INFO: $0 - v0.2"

#set -x

# Try to source configuration from conffile
#
confpattern="vm_create_image"
confpath=""
if [ -e ./$conpattern.conf ]; then
    confpath=./$confpattern.conf
elif [ -e ${HOME}/.$confpattern/$confpattern.conf ]; then
    confpath=${HOME}/.$confpattern/$confpattern.conf
elif [ -e /etc/$confpattern.conf ]; then
    confpath=/etc/$confpattern.conf
else
    echo -n "";	# TODO
fi
if [ "${confpath}" != "" ]; then
    echo "INFO: Reading configuration from ${confpath}"
    . ${confpath} || exit 1
else
    echo "WARNING: no $confpattern config found, using defaults"
fi


# Sanity checks
#
if [ -z "${VM_DESTDIR}" ]; then
    echo "ERROR: Should define VM_DESTDIR"
    exit 1
fi
if [ -z ${VM_NAME} ]; then
    echo "ERROR: Should define VM_NAME"
    exit 1
fi
if [ -z ${VM_TEMPLATE} ]; then
    echo "ERROR: Should define VM_TEMPLATE"
    exit 1
fi
if [ ! -e ${VM_TEMPLATE} ]; then
    echo "ERROR: Cannot find template ${VM_TEMPLATE}"
    exit 1
fi
if [ -e "${VM_DESTDIR}/${VM_NAME}" ]; then
    echo "ERROR: ${VM_NAME} already exists under ${VM_DESTDIR}"
    echo "INFO: Please change ${VM_DESTDIR} or clean its contents"
    exit 1
fi
if [ -z ${VMRUN_SERVERTYPE} ]; then
    echo "ERROR: Should define VMRUN_SERVERTYPE"
    exit 1
fi
if [ -z ${VMRUN_SERVERHOST} ]; then
    echo "ERROR: Should define VMRUN_SERVERHOST"
    exit 1
fi
if [ -z ${VMRUN_USER} ]; then
    echo "ERROR: Should define VMRUN_USER"
    exit 1
fi
if [ "${VMRUN_PASS}" = "" ]; then
        echo -n "Enter VMRUN_PASS: "
        stty -echo
        read VMRUN_PASS
        echo
        stty echo
fi
if [ -z ${VMRUN_PASS} ]; then
    echo "ERROR: Should define VMRUN_PASS"
    exit 1
fi

# Everything seems OK

VMRUN_CMD=vmrun
VMRUN_CMD="$VMRUN_CMD -T $VMRUN_SERVERTYPE"
VMRUN_CMD="$VMRUN_CMD -h $VMRUN_SERVERHOST"
VMRUN_CMD="$VMRUN_CMD -u $VMRUN_USER"
VMRUN_CMD="$VMRUN_CMD -p $VMRUN_PASS"

mkdir -p "${VM_DESTDIR}/${VM_NAME}" || exit 1

VM_DIRNAME="${VM_DESTDIR}/${VM_NAME}"
VMX_PATHNAME="${VM_DIRNAME}/`basename ${VM_TEMPLATE}`"
echo "DBG: VMX_PATHNAME=${VMX_PATHNAME}"
VMX_SERVERPATHNAME="[standard] ${VM_NAME}/`basename ${VM_TEMPLATE}`"
echo "DBG: VMX_SERVERPATHNAME=${VMX_SERVERPATHNAME}"

awk -v vm_name=${VM_NAME} '
//	{
	gsub(/@@VM_NAME@@/, vm_name);
	print $0;
	}
' ${VM_TEMPLATE} >"${VMX_PATHNAME}"

# Change MAC Addresses:
#
#	ethernet0.addressType = "generated"
#	ethernet0.generatedAddress = "00:0c:29:93:74:94"
#	ethernet0.generatedAddressOffset = "0"
#
# TODO

# Create Virtual Disks as specified in .vmx
#
#	scsi0.present = "true"
#	scsi0.virtualDev = "lsilogic"
#	scsi0:0.present = "true"
#	scsi0:0.fileName = "Ubuntu.vmdk"
#	scsi0:0.redo = ""
#	scsi0.pciSlotNumber = "16"
#
SCSI0_VIRTUALDEV=`awk '
/^scsi0.virtualDev/	{
	gsub(/"/, "", $3);
	print $3;
	}
' "${VMX_PATHNAME}"`
echo "DBG: SCSI0_VIRTUALDEV=${SCSI0_VIRTUALDEV}"
VMDK_FILENAME=`awk '
/^scsi0:0.fileName/	{
	gsub(/"/, "", $3);
	print $3;
	}
' "${VMX_PATHNAME}"`
echo "DBG: VMDK_FILENAME=${VMDK_FILENAME}"
#
if [ "${VMDK_FILENAME}" != "" ]; then
    #echo "INFO: Creating virtual disk ${VMDK_FILENAME}"
    (cd "${VM_DIRNAME}" && vmware-vdiskmanager -c \
	-s 100GB -a ${SCSI0_VIRTUALDEV} \
	-t 0 ${VMDK_FILENAME}) || exit 1
fi

# Register the newly created VM
$VMRUN_CMD register "${VMX_SERVERPATHNAME}" || exit 1

# List registered VMs
$VMRUN_CMD listRegisteredVM || exit 1

set -x

# List running VMs
# $VMRUN_CMD list || exit 1

# $VMRUN_CMD stop "[default] xxx/xxx.vmx" || exit 1
# $VMRUN_CMD start "[default] xxx/xxx.vmx" || exit 1

# TODO: $VMRUN_CMD register

# Running a program in a virtual machine with Workstation
# on a Windows host with Windows guest
#
# vmrun -T ws -gu guestUser -gp guestPassword \
#	runProgramInGuest "c:\my VMs\myVM.vmx" \
#	"c:\Program Files\myProgram.exe"

# Running a program in a virtual machine with Server
# on a linux host with linux guest
#
# vmrun -T server -h https://myHost.com/sdk -u hostUser -p hostPassword \
#	-gu guestUser -gp guestPassword \
#	runProgramInGuest "[storage1] vm/myVM.vmx" \
#	/usr/bin/X11/xclock -display :0

# TODO: Not sure where is stdout/stderr...
# $VMRUN_CMD -gu user01 -gp xxxx \
# 	runProgramInGuest "[standard] lupin08/ubuntu-server.vmx" \
# 	/bin/ls -la /

# -----------------------------------------------------------------------------

#VM_BASELINE=${VM_BCKDATE}-${VM_OLDNAME}
#
#if [ ! -e ${VM_BCKDIR}/${VM_BASELINE} ]; then
#    echo "ERROR: Cannot find VM ${VM_BASELINE} under ${VM_BCKDIR}"
#    exit 1
#fi
#if [ -e ${VM_DESTDIR}/${VM_OLDNAME} ]; then
#    echo "ERROR: ${VM_OLDNAME} already exists under ${VM_DESTDIR}"
#    echo "INFO: Please change ${VM_DESTDIR} or clean its contents"
#    exit 1
#fi

##cmd_cat="cat ${VM_BASELINE}.tgz"
#cmd_cat="cat ${VM_BASELINE}.tgz-[0-9][0-9]"
##
##cmd_untar="tar tvz"
#cmd_untar="tar xvz"

#cd ${VM_BCKDIR}/${VM_BASELINE}
#if [ -e md5sum.txt ]; then
#    echo "INFO: Verifying backup file checksums..."
#    md5sum -c md5sum.txt || exit 1
#else
#    echo "WARNING: No md5sum.txt in ${VM_BCKDIR}/${VM_BASELINE}"
#fi

#echo "INFO: Extracting backup into ${VM_DESTDIR}..."
#mkdir -p ${VM_DESTDIR}/${VM_OLDNAME}
#retval=$?
#if [ $retval -ne 0 ]; then
#        echo "ERROR: Cannot create directory under ${VM_DESTDIR}"
#        exit 1
#fi
#(cd ${VM_BCKDIR}/${VM_BASELINE} && ${cmd_cat}) | \
#	(cd ${VM_DESTDIR} && ${cmd_untar})
#retval=$?
#if [ $retval -ne 0 ]; then
#        echo "ERROR: Problems extracting files from ${VM_BASELINE}"
#        exit 1
#fi
#
## TODO: Should verify that rename of displayname works in all cases...
#
#cd ${VM_DESTDIR}
#if [ "${VM_OLDNAME}" != "${VM_NAME}" ]; then
#    mv "${VM_OLDNAME}" "${VM_NAME}"
#    cd "${VM_NAME}"
#    for file in *.vmx; do
#	cp $file $file.ORIG
#	awk -v vm_name="${VM_NAME}" '
#/^display[Nn]ame/	{printf("displayName = \"%s\"\n", vm_name);
#			next }
#//			{print $0}
#' $file.ORIG >$file
#    done
#fi
#
#echo "INFO: Created new VM ${VM_NAME} under ${VM_DESTDIR}"
#echo "INFO: from backup ${VM_BCKDATE} of VM ${VM_BASELINE}"


# === EOF ===
